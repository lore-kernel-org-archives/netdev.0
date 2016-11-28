From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] bpf: cgroup: fix documentation of __cgroup_bpf_update()
Date: Mon, 28 Nov 2016 14:07:56 +0100
Message-ID: <41fa26be-a5dd-f4eb-896d-d115ada3cf9d@zonque.org>
References: <1480331099-20216-1-git-send-email-daniel@zonque.org>
 <583C2B19.7010506@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roszenrami-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, ast-b10kYP2dOMg@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <583C2B19.7010506-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/28/2016 02:03 PM, Daniel Borkmann wrote:
> On 11/28/2016 12:04 PM, Daniel Mack wrote:
>> There's a 'not' missing in one paragraph. Add it.
>>
>> Signed-off-by: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
>> Reported-by: Rami Rosen <roszenrami-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Fixes: 3007098494be ("cgroup: add support for eBPF programs")
> 
> Small nit in subject: s/[PATCH]/[PATCH net-next]/
> 
>>   kernel/bpf/cgroup.c | 6 +++---
>>   1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
>> index a0ab43f..b708e6e 100644
>> --- a/kernel/bpf/cgroup.c
>> +++ b/kernel/bpf/cgroup.c
>> @@ -70,9 +70,9 @@ void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent)
>>    * releases the one that is currently attached, if any. @prog is then made
>>    * the effective program of type @type in that cgroup.
>>    *
>> - * If @prog is %NULL, the currently attached program of type @type is released,
>> - * and the effective program of the parent cgroup (if any) is inherited to
>> - * @cgrp.
>> + * If @prog is not %NULL, the currently attached program of type @type is
>> + * released, and the effective program of the parent cgroup (if any) is
>> + * inherited to @cgrp.
> 
> Both paragraphs for __cgroup_bpf_update() currently say:
> 
> [...]
>   * If @prog is %NULL, this function attaches a new program to the cgroup and
>   * releases the one that is currently attached, if any. @prog is then made
>   * the effective program of type @type in that cgroup.
>   *
>   * If @prog is %NULL, the currently attached program of type @type is released,
>   * and the effective program of the parent cgroup (if any) is inherited to
>   * @cgrp.
> [...]
> 
> It looks to me that you are 'fixing' the wrong location. First paragraph is
> actually missing a "not", which would then also align with what the code does.
> 

Argh, sorry. Will resend.
