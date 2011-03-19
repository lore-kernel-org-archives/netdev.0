From: Piotr Hosowicz <piotr@hosowicz.com>
Subject: Re: [PATCH] r8169: fix a bug in rtl8169_init_phy()
Date: Sat, 19 Mar 2011 16:52:03 +0100
Message-ID: <4D84D123.8060903@example.com>
References: <4D84A46B.1000407@example.com> <1300548821.2831.28.camel@edumazet-laptop> <1300549151.2831.32.camel@edumazet-laptop> <201103191641.41718.oliver@neukum.org>
Reply-To: piotr@hosowicz.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Anca Emanuel <anca.emanuel@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201103191641.41718.oliver@neukum.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19.03.2011 16:41, Oliver Neukum wrote:
> Am Samstag, 19. M=C3=A4rz 2011, 16:39:11 schrieben Sie:
>> Le samedi 19 mars 2011 =C3=A0 16:33 +0100, Eric Dumazet a =C3=A9crit=
 :
>>> Le samedi 19 mars 2011 =C3=A0 16:31 +0100, Oliver Neukum a =C3=A9cr=
it :
>>>> Am Samstag, 19. M=C3=A4rz 2011, 16:18:50 schrieb Eric Dumazet:
>>>>
>>>>> Problem comes from commit 54405cde762408b00a445466a40da4f7f33a847=
9
>>>>> (r8169: support control of advertising.)
>>>>>
>>>>> Reverting it brings back NIC for me
>>>>
>>>> Odd. It worked for me. Are you testing on a gigabit switch? Could =
you send
>>>> me dmesg? Does it work if you use ethtool to advertise a lower spe=
ed?
>>>>
>>>> 	Regards
>>>> 		Oliver
>>>
>>> I found the bug, I am sending a patch in two minutes.
>>>
>>
>> Here it is
>>
>> [PATCH] r8169: fix a bug in rtl8169_init_phy()
>>
>> commit 54405cde7624 (r8169: support control of advertising.)
>> introduced a bug in rtl8169_init_phy()
>
> Thank you. I feel like banging my head against something.

If it will work I will be banging against the wall. I am missing for a=20
fresh new kernel with networking.

--=20
Szef TVN24 do dziennikarzy: Kochani, przez dwa lata walili=C5=9Bmy w ob=
=C3=B3z
rz=C4=85dz=C4=85cy. Tak dalej byc nie mo=C5=BCe. Jeste=C5=9Bmy telewizj=
=C4=85 niezale=C5=BCn=C4=85 i to
zobowi=C4=85zuje. Teraz b=C4=99dziemy kopa=C4=87 w opozycj=C4=99.
NP: Big Big Train - Victorian Brickwork
NB: 2.6.38-git3
