From: Sam Creasey <sammy@sammy.net>
Subject: Re: [BK PATCHES] 2.6.x experimental net driver queue
Date: Tue, 18 Nov 2003 21:19:20 +0000 (UTC)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.40.0311191703120.6278-100000__13887.194885365$1069190360@sun3>
References: <Pine.GSO.4.21.0311181205460.6448-100000@waterleaf.sonytel.be>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, <netdev@oss.sgi.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Al Viro <viro@parcelfarce.linux.theplanet.co.uk>,
	Linux/m68k <linux-m68k@lists.linux-m68k.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
Date: Wed, 19 Nov 2003 17:08:01 -0500 (EST)
To: Geert Uytterhoeven <geert@linux-m68k.org>
In-Reply-To: <Pine.GSO.4.21.0311181205460.6448-100000@waterleaf.sonytel.be>
List-Id: netdev.vger.kernel.org



On Tue, 18 Nov 2003, Geert Uytterhoeven wrote:

> On Mon, 17 Nov 2003, Geert Uytterhoeven wrote:
> > On Sun, 16 Nov 2003, Jeff Garzik wrote:
> > > Yet more updates.  Syncing with Andrew Morton, and more syncing with Al
> > > Viro.
> > >
> > > No users of init_etherdev remain in the tree.  (yay!)
> >
> > Here are some (untested, except for cross-gcc) fixes for the m68k-related
> > drivers:
>
> I forget to test the Sun-3 drivers:
>   - sun3_82586.c:
>       o add missing casts to iounmap() calls
>       o fix parameter of free_netdev()
>   - sun3lance.c: add missing casts to iounmap() calls
>
> Note that sun3_82586.c no longer compiles since SUN3_82586_TOTAL_SIZE is not
> defined. Sammy, is it OK to use PAGE_SIZE for that, since that's what's passed
> to ioremap()?

Should be...  I looked back through a few versions of the code, and I'm
not even sure what SUN3_82586_TOTAL_SIZE even was (appears I commented
that line out long ago anyway).  (I'm also amazed just how much of that
driver I've forgotten in the last year or two :)

-- Sam
