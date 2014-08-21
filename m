From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH net-next 1/2] sched: introduce nr_running_this_cpu()
Date: Thu, 21 Aug 2014 15:52:03 +0200
Message-ID: <20140821135203.GA29591@gmail.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1408608310-13579-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Jason Wang <jasowang@redhat.com> wrote:

> This patch introduces a helper nr_running_this_cpu() to return the
> number of runnable processes in current cpu.
> 
> The first user will be net rx busy polling. It will use this to exit
> the busy loop when it finds more than one processes is runnable in
> current cpu. This can give us better performance of busy polling under
> heavy load.

s/one processes/one process

More importantly, please Cc: scheduler maintainers and lkml to 
both patches, so that the whole intent of the change can be 
reviewed, in full context.

Thanks,

	Ingo
