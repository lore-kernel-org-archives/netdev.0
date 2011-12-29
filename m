From: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on low-end broads.
Date: Fri, 30 Dec 2011 00:37:17 +0100
Message-ID: <CACPM=kVfsXgFhKheevTS1pm7kCoezKO3M+102O=PRbXzxebxxg@mail.gmail.com>
References: <CACPM=kXOddA+T6vQPijR6sh8x5cMO=4baKGeKxEmMKG896Lz4g@mail.gmail.com>
	<20111229153902.GB21946@electric-eye.fr.zoreil.com>
	<20111229183902.GC21946@electric-eye.fr.zoreil.com>
	<20111229.170514.1766899380937848638.davem@davemloft.net>
	<CACPM=kV8NwYLAdODQHxYmJ21X0RmZ8KJT9szKdY2xa-DsesvQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, shemminger@vyatta.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rl@hellgate.ch
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACPM=kV8NwYLAdODQHxYmJ21X0RmZ8KJT9szKdY2xa-DsesvQg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/12/30 Bjarke Istrup Pedersen <gurligebis@gentoo.org>:
> 2011/12/29 David Miller <davem@davemloft.net>:
>> From: Francois Romieu <romieu@fr.zoreil.com>
>> Date: Thu, 29 Dec 2011 19:39:02 +0100
>>
>>> Francois Romieu <romieu@fr.zoreil.com> :
>>> [...]
>>>> Feel free to try the extra "new year's eve week end is getting clo=
ser"
>>>> patch below (against net-next).
>>>>
>>>> You have been warned.
>>>
>>> The one below could be a bit better.
>>
>> Obviously you'll need to resolve the use of rp->lock as an IRQ safe =
lock
>> in {get,src}_wol() so that this lock is consistently used as a BH sa=
fe
>> lock. =A0Your "Huh?" comments make it clear you are aware of this TO=
DO. :-)
>>
>> But other than that this patch looks good to me, just some testing a=
nd
>> debugging are needed.
>
> I got it to boot, had to revert another patch introduced in 3.1.5
> that's causing alot of people problems, but thats another talk :)
>
> It boots fine, untill it tries to bring up an interface, which causes
> it to fails with a kernel panic.
> Here is the output of the panic:
> http://dev.gentoo.org/~gurligebis/kernel/panic.txt
>
> /Bjarke

Hmm, it seems like this problem isn't related to the driver, but
related to the current HEAD of net-next :)

Would it be a problem if I try and use the patch on top of a clean
3.1.6 kernel ?

/Bjarke

>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kern=
el" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at =A0http://www.tux.org/lkml/
