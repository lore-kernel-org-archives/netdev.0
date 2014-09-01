From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process
 is runnable
Date: Mon, 01 Sep 2014 09:39:39 +0300
Message-ID: <540414AB.9000004@linux.intel.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com> <1408608310-13579-2-git-send-email-jasowang@redhat.com> <1408683665.5648.69.camel@marge.simpson.net> <53F6F14B.1030609@redhat.com> <20140822074224.GB7372@gmail.com> <53FFEEC0.4000304@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Mike Galbraith <umgwanakikbuti@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@elte.hu>
To: Jason Wang <jasowang@redhat.com>, Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53FFEEC0.4000304@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 29/08/2014 06:08, Jason Wang wrote:
> Yes, but rx busy polling only works in process context and does not
> disable bh, so it may be not an issue.

sk_busy_loop() uses rcu_read_lock_bh(), so it does run with bh disabled.

-Eliezer
