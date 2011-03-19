From: Piotr Hosowicz <piotr@hosowicz.com>
Subject: Re: [PATCH] r8169: fix a bug in rtl8169_init_phy()
Date: Sat, 19 Mar 2011 17:03:35 +0100
Message-ID: <4D84D3D7.8000901@example.com>
References: <4D84A46B.1000407@example.com>	 <AANLkTimFGeHYEOxx=h883rRJL463g1CBUDS0wGM-52Nj@mail.gmail.com>	 <1300547930.2831.27.camel@edumazet-laptop>	 <201103191631.07952.oliver@neukum.org>	 <1300548821.2831.28.camel@edumazet-laptop> <1300549151.2831.32.camel@edumazet-laptop>
Reply-To: piotr@hosowicz.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>,
	Anca Emanuel <anca.emanuel@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 6.27.mail-out.ovh.net ([46.105.50.195]:37467 "HELO
	27.mail-out.ovh.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with SMTP id S1756497Ab1CSQK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2011 12:10:27 -0400
In-Reply-To: <1300549151.2831.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19.03.2011 16:39, Eric Dumazet wrote:
> Le samedi 19 mars 2011 =C3=A0 16:33 +0100, Eric Dumazet a =C3=A9crit =
:
>> Le samedi 19 mars 2011 =C3=A0 16:31 +0100, Oliver Neukum a =C3=A9cri=
t :
>>> Am Samstag, 19. M=C3=A4rz 2011, 16:18:50 schrieb Eric Dumazet:
>>>
>>>> Problem comes from commit 54405cde762408b00a445466a40da4f7f33a8479
>>>> (r8169: support control of advertising.)
>>>>
>>>> Reverting it brings back NIC for me
>>>
>>> Odd. It worked for me. Are you testing on a gigabit switch? Could y=
ou send
>>> me dmesg? Does it work if you use ethtool to advertise a lower spee=
d?
>>>
>>> 	Regards
>>> 		Oliver
>>
>> I found the bug, I am sending a patch in two minutes.

I do not understand. I reverted the commit you mentioned and am buildin=
g=20
now. Will it suffice?

Regards,

Piotr Hosowicz

--=20
TV: "W tej chwili, =C5=BCe si=C4=99 tak wyra=C5=BC=C4=99, zaliczonych m=
amy 17 zawodniczek."
NP: Big Big Train - Victorian Brickwork
NB: 2.6.38-git3
