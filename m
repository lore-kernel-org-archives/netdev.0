From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 1/2] sched: introduce nr_running_this_cpu()
Date: Fri, 22 Aug 2014 15:27:32 +0800
Message-ID: <53F6F0E4.4070800@redhat.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com> <20140821135203.GA29591@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140821135203.GA29591@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/21/2014 09:52 PM, Ingo Molnar wrote:
> * Jason Wang <jasowang@redhat.com> wrote:
>
>> This patch introduces a helper nr_running_this_cpu() to return the
>> number of runnable processes in current cpu.
>>
>> The first user will be net rx busy polling. It will use this to exit
>> the busy loop when it finds more than one processes is runnable in
>> current cpu. This can give us better performance of busy polling under
>> heavy load.
> s/one processes/one process
>
> More importantly, please Cc: scheduler maintainers and lkml to 
> both patches, so that the whole intent of the change can be 
> reviewed, in full context.
>
> Thanks,
>
> 	Ingo

Will do this.

Thanks
