From: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on low-end broads.
Date: Sat, 31 Dec 2011 02:37:36 +0100
Message-ID: <CACPM=kWn41S85eLgj4G+c6cN0WBgqF=6MigSwa9QBOxD1Uh64A@mail.gmail.com>
References: <CACPM=kV8NwYLAdODQHxYmJ21X0RmZ8KJT9szKdY2xa-DsesvQg@mail.gmail.com>
	<CACPM=kVfsXgFhKheevTS1pm7kCoezKO3M+102O=PRbXzxebxxg@mail.gmail.com>
	<20111229235312.GA27092@electric-eye.fr.zoreil.com>
	<CACPM=kXTqY1kVWrEMB-Z0Lqy6t+rXvMzixcSUy7fAz6g_ajV9g@mail.gmail.com>
	<20111230125655.GA32031@electric-eye.fr.zoreil.com>
	<CACPM=kVBxcL1_Z9zVvnEEdEgAc0rbAAbzkcocz4OYWQ2xn6VmQ@mail.gmail.com>
	<20111230180347.GA3647@electric-eye.fr.zoreil.com>
	<CACPM=kXWXUE+JcVhkz-6tGZ2YyteN9sGA80+Pnw6+LaJ-eNWBA@mail.gmail.com>
	<20111230215024.GA5513@electric-eye.fr.zoreil.com>
	<CACPM=kUxSRhDc2EqgceBRTFgBei7dh3_n7bPyoH=8aNC_uq4FA@mail.gmail.com>
	<20111230221938.GA6197@electric-eye.fr.zoreil.com>
	<CACPM=kXAr46BXAc3t8puRB37NeFy_ZEOWZa0H=DnSioagSLpxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rl@hellgate.ch
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACPM=kXAr46BXAc3t8puRB37NeFy_ZEOWZa0H=DnSioagSLpxA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/12/30 Bjarke Istrup Pedersen <gurligebis@gentoo.org>:
> 2011/12/30 Francois Romieu <romieu@fr.zoreil.com>:
>> Bjarke Istrup Pedersen <gurligebis@gentoo.org> :
>> [...]
>>> Does not build with patch:
>>
>> Neither did it here. My head is already elsewhere.
>>
>> [...]
>>> Wouldn't it be an idea to move the declarations to a via-rhine.h fi=
le,
>>> and include it, to work around it, and seperate it like it should b=
e?
>>
>> Code could be correctly ordered too. Forward declare it. It's good e=
nough
>> in the meantime.
>
> Forward declaring it makes it compile just fine.
>
> I'll try and do some stress test of it when the rest of the house goe=
s
> to sleep, so I don't cut off the net :)
>
> /Bjarke

Okay, this is beginning to look great.
Just tried randomly up'ing/down'ing the interfaces on the router while
there was alot of trafic going between them (a client downloading a
knoppix live dvd using bittorrent) - survived without a single bump.
Also tried connect a machine to one of the ports, and copying a large
file across (something that before could make it lock up within 15
secords) - also worked without any problems - CPU usage around 15%
(mostly "top" using that), so thats not bad at all.

Is there any other testcases that I should try out?

/Bjarke

>> --
>> Ueimor
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kern=
el" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at =A0http://www.tux.org/lkml/
