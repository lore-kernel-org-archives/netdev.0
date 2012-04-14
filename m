From: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Subject: Re: via-rhine: Problem with lost link after a while
Date: Sat, 14 Apr 2012 17:10:51 +0200
Message-ID: <CACPM=kUskdtJt6FxT5xkXfObFj-CEU6799hX6iQ5dZLZw6M1=w@mail.gmail.com>
References: <CACPM=kWa=UWuCMaYAtVMGJ7pzCy-PfyNRWBSuJnTZGtssU0W6g@mail.gmail.com>
	<20120410204249.GA26627@electric-eye.fr.zoreil.com>
	<CACPM=kWsU8QZOHqwEThTQCuSSvaTDoxO1d17EyoW=+kx8QG3vw@mail.gmail.com>
	<20120410225534.GA28480@electric-eye.fr.zoreil.com>
	<CACPM=kXGyxgfwzMxAhx-jUL1hYMAqWc7=9gfYcgV=xebAQ=+Og@mail.gmail.com>
	<20120414100601.GA11698@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Svenning_S=F8rensen?= <sss@secomea.com>,
	Andreas Mohr <andi@lisas.de>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120414100601.GA11698@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

14. apr. 2012 12.06 skrev Francois Romieu <romieu@fr.zoreil.com>:
> Bjarke Istrup Pedersen <gurligebis@gentoo.org> :
> [...]
>> I've been testing v3.4-rc2 with this patch applied for the past few
>> days, with alot of trafic across, both incoming and outgoing, with V=
PN
>> which is normally what can trigger problems, and it seems rock solid
>> :o)
>
> Thanks.
>
>> Do you need me to do any specific testing of this patch?
>
> See below.
>
> Changes of behavior should be reported for this patch over plain 3.4-=
rc2 or
> current 3.3-stable as both include Andreas's fix.
>
> Otherwise it can not be labelled it as a fix : it does not go into 3.=
4-rc
> nor 3.3-stable but proceeds through net-next where it will land into
> 3.5-rc then -stable.
>
> One can not exercize the Tx xmit vs napi Tx completion race part of t=
he
> patch with a single core. Afaiui non-Soekris users are needed here.
>
> Even if you don't experience change of behavior over 3.4-rc or 3.3-st=
able,
> some longterm use of this driver would be welcome. It may end as an e=
ffort
> for 3.5-rc though.

Okay, I'll keep staying up to date with 3.4-rcX and report if anything =
breaks.
Going for v3.5-rc should be fine AFAICS :-)

/Bjarke

> --
> Ueimor
>
> Will code drivers for food.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
