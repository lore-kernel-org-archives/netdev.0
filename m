From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: drivers/net/ariadne.c:165: error: 'set_multicast_list' undeclared
	here (not in a function)
Date: Tue, 26 Jan 2010 09:57:05 +0100
Message-ID: <10f740e81001260057h37f3494dvefa3a37b2e1453a5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux-Next <linux-next@vger.kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752740Ab0AZI5Q@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

http://kisskb.ellerman.id.au/kisskb/buildresult/2076964/

drivers/net/ariadne.c:165: error: 'set_multicast_list' undeclared here
(not in a function)

Seems to be broken by:

commit a271623f871dda970319ca15dfad3a8c8c36249f
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Fri Jan 22 10:13:10 2010 +0000

    netdev: remove certain HAVE_ macros

    After netdev_ops compat code HAVE_* macros aren't needed, in fact
    they _will_ result in compile breakage for out of tree drivers.

    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
