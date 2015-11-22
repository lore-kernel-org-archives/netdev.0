From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: MULTIPLE_TABLES and IP_ADVANCED_ROUTER
Date: Sun, 22 Nov 2015 11:03:18 +0100
Message-ID: <CAMuHMdXZpxnrU=FfFcf3sgX+Ym3RCVLA7dn_8mgUBpby18uDzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:35928 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbbKVKDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 05:03:19 -0500
Received: by oiww189 with SMTP id w189so93234244oiw.3
        for <netdev@vger.kernel.org>; Sun, 22 Nov 2015 02:03:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

        Hi,

Is there a reason why IP_MULTIPLE_TABLES and IP_MROUTE_MULTIPLE_TABLES
depend on IP_ADVANCED_ROUTER, while their IPV6 counterparts don't?

net/ipv4/Kconfig:

    config IP_MULTIPLE_TABLES
            bool "IP: policy routing"
            depends on IP_ADVANCED_ROUTER
            select FIB_RULES

    config IP_MROUTE_MULTIPLE_TABLES
            bool "IP: multicast policy routing"
            depends on IP_MROUTE && IP_ADVANCED_ROUTER
            select FIB_RULES


net/ipv6/Kconfig:

    config IPV6_MULTIPLE_TABLES
            bool "IPv6: Multiple Routing Tables"
            select FIB_RULES

    config IPV6_MROUTE_MULTIPLE_TABLES
            bool "IPv6: multicast policy routing"
            depends on IPV6_MROUTE
            select FIB_RULES

Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
