From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] pktgen dependency (was: Re: Linux 2.4.27-pre1)
Date: Fri, 23 Apr 2004 16:58:58 +0200 (MEST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.GSO.4.58.0404231644470.15793@waterleaf.sonytel.be>
References: <20040422130651.GB18358@logos.cnet>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Development <linux-kernel@vger.kernel.org>,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, netdev@oss.sgi.com
In-Reply-To: <20040422130651.GB18358@logos.cnet>
List-Id: netdev.vger.kernel.org


The packet generator doesn't compile if procfs is disabled.
IIRC, there was an agreement that this dependency is needed:

--- linux-2.4.27-pre1/net/Config.in.orig	2003-10-01 20:49:26.000000000 +0200
+++ linux-2.4.27-pre1/net/Config.in	2004-04-23 14:43:58.000000000 +0200
@@ -99,7 +99,7 @@

 mainmenu_option next_comment
 comment 'Network testing'
-tristate 'Packet Generator (USE WITH CAUTION)' CONFIG_NET_PKTGEN
+dep_tristate 'Packet Generator (USE WITH CAUTION)' CONFIG_NET_PKTGEN $CONFIG_PROC_FS
 endmenu

 endmenu

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
