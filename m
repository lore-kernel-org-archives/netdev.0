From: Boaz Harrosh <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 19/24] sunrpc: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 16:33:54 -0700
Message-ID: <4E5C21E2.4070903@panasas.com>
References: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4EE9@SACMVEXC2-PRD.hq.netapp.com><20110829.143751.1153162956919885670.davem@davemloft.net><4E5C0AB3.90401@panasas.com> <20110829.180348.1774953636752413432.davem@davemloft.net> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4FAF@SACMVEXC2-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	<bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, <neilb-l3A5Bk7waGM@public.gmane.org>,
	<linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Myklebust, Trond" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4FAF-hX7t0kiaRRrlMGe9HJ1VYQK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/29/2011 04:25 PM, Myklebust, Trond wrote:
>> -----Original Message-----
>> From: David Miller [mailto:davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org]
<>
>> They've been doing this for years, so obviously they haven't bothered
>> you enough to care up to this point.
>>
>> All of this pushback is pure uneducated noise, please stop blocking
>> progress with poorly informed objections.
> 
> I can see that slub.c has the slab_out_of_memory() function that
> (although ratelimited) warns you if the allocation failed. However I
> can't find any equivalent for slab.c or slob.c.
> 

OK That would explain why I never saw it in my debugging. For some reason
I'm always using slab. 

Which one is the best for development and memory problems debugging?

> Trond

Thanks
Boaz
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
