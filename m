From: Piotr Hosowicz <piotr@hosowicz.com>
Subject: Re: [PATCH] r8169: fix a bug in rtl8169_init_phy()
Date: Sat, 19 Mar 2011 19:59:05 +0100
Message-ID: <4D84FCF9.8010801@example.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300549151.2831.32.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
>>
>
> Here it is
>
> [PATCH] r8169: fix a bug in rtl8169_init_phy()
>
> commit 54405cde7624 (r8169: support control of advertising.)
> introduced a bug in rtl8169_init_phy()
>
> Reported-by: Piotr Hosowicz<piotr@hosowicz.com>
> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
> Cc: Oliver Neukum<oliver@neukum.org>
> Cc: Francois Romieu<romieu@fr.zoreil.com>

Tested-by: Piotr Hosowicz<piotr@hosowicz.com>

Works OK now.

Regards,

Piotr Hosowicz

--=20
Parafrazuj=C4=85c Einsteina: w socjali=C5=BAmie s=C4=85 dwa zawody z pr=
zy-
sz=C5=82o=C5=9Bci=C4=85: piekarz i urz=C4=99dnik, chocia=C5=BC co do pi=
erwszego to
nie mam pewno=C5=9Bci. (by Kubarek, http://blog.kubarek.info/)
NP: Karmakanic - Send a message from the heart
NB: 2.6.38-20110319-1638-net++
