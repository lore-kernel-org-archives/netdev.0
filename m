From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH, RESEND] Add MWI workaround for Tulip DC21143
Date: Tue, 7 Mar 2006 10:32:13 +0100 (CET)
Message-ID: <Pine.LNX.4.62.0603071031520.5292@pademelon.sonytel.be>
References: <20060129230816.GD4094@colonel-panic.org> <20060218220851.GA1601@colonel-panic.org>
 <20060306225131.GA23327@unjust.cyrius.com> <20060306231530.GB16082@electric-eye.fr.zoreil.com>
 <20060307035824.GA24018@linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Martin Michlmayr <tbm@cyrius.com>, netdev@vger.kernel.org,
	Linux/MIPS Development <linux-mips@linux-mips.org>
Return-path: <linux-mips-bounce@linux-mips.org>
To: Ralf Baechle <ralf@linux-mips.org>
In-Reply-To: <20060307035824.GA24018@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Tue, 7 Mar 2006, Ralf Baechle wrote:
> On Tue, Mar 07, 2006 at 12:15:30AM +0100, Francois Romieu wrote:
> 
> > [...]
> > > Does anyone have comments regarding this patch?  I received
> > > confirmation from a number of Debian users that this patch
> > > significantly improves the lockup situation on Cobalt, so
> > > it would be nice if it could go in.
> > 
> > I'll queue it with the pending de2104x fix(es ?) during my next
> > upkeep.
> 
> I'm just not convinced of having such a workaround as a build option.
> The average person building a a kernel will probably not know if the
> option needs to be enabled or not.

Indeed, if it's mentioned in the errata of the chip, the driver should take
care of it.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
