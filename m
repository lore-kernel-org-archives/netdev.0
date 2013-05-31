From: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: cw1200 "sbus" conflicts with SPARC "sbus"
Date: Fri, 31 May 2013 11:31:05 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1305311127200.4645@ayla.of.borg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Solomon Peachy <pizza-pCgMCH4qpMRg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


sparc64/allmodconfig:

drivers/net/wireless/cw1200/hwio.c:51:21: error: macro "sbus_memcpy_fromio" passed 4 arguments, but takes just 3
drivers/net/wireless/cw1200/hwio.c:66:19: error: macro "sbus_memcpy_toio" passed 4 arguments, but takes just 3

http://kisskb.ellerman.id.au/kisskb/buildresult/8846508/

At first I thought it was a bad/old implementation of a real SPARC sbus
driver.  but it seems the two sbusses are completely unrelated.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
