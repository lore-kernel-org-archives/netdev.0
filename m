From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] pktgen dependency (was: Re: Linux 2.4.27-pre1)
Date: Sun, 25 Apr 2004 12:19:11 +0200 (MEST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.GSO.4.58.0404251218430.11039@waterleaf.sonytel.be>
References: <20040422130651.GB18358@logos.cnet>
 <Pine.GSO.4.58.0404231644470.15793@waterleaf.sonytel.be>
 <20040423163938.013f362f.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, netdev@oss.sgi.com,
	Linux Kernel Development <linux-kernel@vger.kernel.org>,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040423163938.013f362f.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Fri, 23 Apr 2004, David S. Miller wrote:
> On Fri, 23 Apr 2004 16:58:58 +0200 (MEST)
> Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>
> > The packet generator doesn't compile if procfs is disabled.
> > IIRC, there was an agreement that this dependency is needed:
>
> Applied, thanks Geert.  Can you cook up a 2.6.x variant as well
> if that is needed too?

2.6.6-rc2 already has

    config NET_PKTGEN
	    tristate "Packet Generator (USE WITH CAUTION)"
	    depends on PROC_FS

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
