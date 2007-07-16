From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [2.6 patch] more ACSI removal
Date: Mon, 16 Jul 2007 15:01:13 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0707161457300.7535@anakin>
References: <20070712234553.GR3492@stusta.de> <Pine.LNX.4.64.0707130909170.8296@anakin>
 <20070716121541.GH5195@kernel.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Adrian Bunk <bunk@stusta.de>, Boaz Harrosh <bharrosh@panasas.com>,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org, zippel@linux-m68k.org,
	linux-m68k@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932133AbXGPNBa@vger.kernel.org>
In-Reply-To: <20070716121541.GH5195@kernel.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Jul 2007, Jens Axboe wrote:
> On Fri, Jul 13 2007, Geert Uytterhoeven wrote:
> > On Fri, 13 Jul 2007, Adrian Bunk wrote:
> > > This patch removes some code that became dead code after the ATARI_ACSI 
> > > removal.
> > 
> > When was it removed? Nobody seems to have informed the m68k people...
> 
> It hasn't even been compiling for 5 years, so it can't be that big of an
> issue. I thought you had been cc'ed on the discussion, but I can't seem
> to find the thread now even.

OK, in that case it doens't make much sense to keep ATARI_SLM, ATARI_BIONET,
and ATARI_PAMSNET. Those who desperately(?) need it can resurvive ACSI
if they want to...

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
