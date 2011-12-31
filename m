From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on low-end broads.
Date: Sat, 31 Dec 2011 13:17:10 +0100
Message-ID: <20111231121710.GB9842@electric-eye.fr.zoreil.com>
References: <CACPM=kXTqY1kVWrEMB-Z0Lqy6t+rXvMzixcSUy7fAz6g_ajV9g@mail.gmail.com> <20111230125655.GA32031@electric-eye.fr.zoreil.com> <CACPM=kVBxcL1_Z9zVvnEEdEgAc0rbAAbzkcocz4OYWQ2xn6VmQ@mail.gmail.com> <20111230180347.GA3647@electric-eye.fr.zoreil.com> <CACPM=kXWXUE+JcVhkz-6tGZ2YyteN9sGA80+Pnw6+LaJ-eNWBA@mail.gmail.com> <20111230215024.GA5513@electric-eye.fr.zoreil.com> <CACPM=kUxSRhDc2EqgceBRTFgBei7dh3_n7bPyoH=8aNC_uq4FA@mail.gmail.com> <20111230221938.GA6197@electric-eye.fr.zoreil.com> <CACPM=kXAr46BXAc3t8puRB37NeFy_ZEOWZa0H=DnSioagSLpxA@mail.gmail.com> <CACPM=kWn41S85eLgj4G+c6cN0WBgqF=6MigSwa9QBOxD1Uh64A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rl@hellgate.ch
To: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACPM=kWn41S85eLgj4G+c6cN0WBgqF=6MigSwa9QBOxD1Uh64A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjarke Istrup Pedersen <gurligebis@gentoo.org> :
[...]
> Also tried connect a machine to one of the ports, and copying a large
> file across (something that before could make it lock up within 15
> secords) - also worked without any problems - CPU usage around 15%
> (mostly "top" using that), so thats not bad at all.
> 
> Is there any other testcases that I should try out?

Same thing + random ethtool link management commands.
Same thing + random cable unplug/plug.
Same thing + pktgen facing the lan interface.

Everything at the same time.

-- 
Ueimor
