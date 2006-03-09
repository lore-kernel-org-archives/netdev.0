From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH, RESEND] Add MWI workaround for Tulip DC21143
Date: Thu, 9 Mar 2006 23:44:56 +0100
Message-ID: <20060309224456.GB9103@electric-eye.fr.zoreil.com>
References: <20060129230816.GD4094@colonel-panic.org> <20060218220851.GA1601@colonel-panic.org> <20060306225131.GA23327@unjust.cyrius.com> <20060306231530.GB16082@electric-eye.fr.zoreil.com> <20060307035824.GA24018@linux-mips.org> <Pine.LNX.4.62.0603071031520.5292@pademelon.sonytel.be> <20060308224139.GA7536@electric-eye.fr.zoreil.com> <Pine.LNX.4.62.0603091032490.9741@pademelon.sonytel.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>,
	Martin Michlmayr <tbm@cyrius.com>, netdev@vger.kernel.org,
	Linux/MIPS Development <linux-mips@linux-mips.org>,
	"P. Horton" <pdh@colonel-panic.org>
Return-path: <linux-mips-bounce@linux-mips.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0603091032490.9741@pademelon.sonytel.be>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Geert Uytterhoeven <geert@linux-m68k.org> :
[...]
> So when compiling for Cobalt, we work around the hardware bug, while for other
> platforms, we just disable MWI?
> 
> Wouldn't it be possible to always (I mean, when a rev 65 chip is detected)
> work around the bug?

Of course it is possible but it is not the same semantic as the initial
patch (not that I know if it is right or not).

So:
- does the issue exist beyond Cobalt hosts ?
- is the fix Cobalt-only ?

-- 
Ueimor
