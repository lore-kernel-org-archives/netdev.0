From: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on low-end broads.
Date: Sun, 1 Jan 2012 22:15:44 +0100
Message-ID: <CACPM=kUQ8FB6H9CUNmpRQf_QQ6gY3oP5YHMRPm7xhG11eoHePQ@mail.gmail.com>
References: <CACPM=kXTqY1kVWrEMB-Z0Lqy6t+rXvMzixcSUy7fAz6g_ajV9g@mail.gmail.com>
	<20111230125655.GA32031@electric-eye.fr.zoreil.com>
	<CACPM=kVBxcL1_Z9zVvnEEdEgAc0rbAAbzkcocz4OYWQ2xn6VmQ@mail.gmail.com>
	<20111230180347.GA3647@electric-eye.fr.zoreil.com>
	<CACPM=kXWXUE+JcVhkz-6tGZ2YyteN9sGA80+Pnw6+LaJ-eNWBA@mail.gmail.com>
	<20111230215024.GA5513@electric-eye.fr.zoreil.com>
	<CACPM=kUxSRhDc2EqgceBRTFgBei7dh3_n7bPyoH=8aNC_uq4FA@mail.gmail.com>
	<20111230221938.GA6197@electric-eye.fr.zoreil.com>
	<CACPM=kXAr46BXAc3t8puRB37NeFy_ZEOWZa0H=DnSioagSLpxA@mail.gmail.com>
	<CACPM=kWn41S85eLgj4G+c6cN0WBgqF=6MigSwa9QBOxD1Uh64A@mail.gmail.com>
	<20111231121710.GB9842@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rl@hellgate.ch
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111231121710.GB9842@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/12/31 Francois Romieu <romieu@fr.zoreil.com>:
> Bjarke Istrup Pedersen <gurligebis@gentoo.org> :
> [...]
>> Also tried connect a machine to one of the ports, and copying a larg=
e
>> file across (something that before could make it lock up within 15
>> secords) - also worked without any problems - CPU usage around 15%
>> (mostly "top" using that), so thats not bad at all.
>>
>> Is there any other testcases that I should try out?
>
> Same thing + random ethtool link management commands.
> Same thing + random cable unplug/plug.
> Same thing + pktgen facing the lan interface.
>
> Everything at the same time.

Btw. - I have split up the via-rhine.c file (with all the changes you
have sent me) into via-rhine.c and via-rhine.h , like it should be :-)
I'll send it shortly after this mail - could you incorporate it into yo=
ur work?

/Bjarke

> --
> Ueimor
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
