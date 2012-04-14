From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: via-rhine: Problem with lost link after a while
Date: Sat, 14 Apr 2012 12:06:01 +0200
Message-ID: <20120414100601.GA11698@electric-eye.fr.zoreil.com>
References: <CACPM=kWa=UWuCMaYAtVMGJ7pzCy-PfyNRWBSuJnTZGtssU0W6g@mail.gmail.com> <20120410204249.GA26627@electric-eye.fr.zoreil.com> <CACPM=kWsU8QZOHqwEThTQCuSSvaTDoxO1d17EyoW=+kx8QG3vw@mail.gmail.com> <20120410225534.GA28480@electric-eye.fr.zoreil.com> <CACPM=kXGyxgfwzMxAhx-jUL1hYMAqWc7=9gfYcgV=xebAQ=+Og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Svenning =?utf-8?B?U8O4cmVuc2Vu?= <sss@secomea.com>,
	Andreas Mohr <andi@lisas.de>
To: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACPM=kXGyxgfwzMxAhx-jUL1hYMAqWc7=9gfYcgV=xebAQ=+Og@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjarke Istrup Pedersen <gurligebis@gentoo.org> :
[...]
> I've been testing v3.4-rc2 with this patch applied for the past few
> days, with alot of trafic across, both incoming and outgoing, with VPN
> which is normally what can trigger problems, and it seems rock solid
> :o)

Thanks.

> Do you need me to do any specific testing of this patch?

See below. 

Changes of behavior should be reported for this patch over plain 3.4-rc2 or
current 3.3-stable as both include Andreas's fix.

Otherwise it can not be labelled it as a fix : it does not go into 3.4-rc
nor 3.3-stable but proceeds through net-next where it will land into
3.5-rc then -stable.

One can not exercize the Tx xmit vs napi Tx completion race part of the
patch with a single core. Afaiui non-Soekris users are needed here.

Even if you don't experience change of behavior over 3.4-rc or 3.3-stable,
some longterm use of this driver would be welcome. It may end as an effort
for 3.5-rc though.

--
Ueimor

Will code drivers for food.
