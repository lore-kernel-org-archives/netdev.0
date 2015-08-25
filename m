From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [[net-next] lo uses DEPRECATED zero tx_queue_len - convert driver to
 use IFF_NO_QUEUE instead
Date: Tue, 25 Aug 2015 13:16:41 +0200
Message-ID: <CAMuHMdX6O3_wtWagwAKgVd=aifXjVd5rw8VczF18VS9+Mm30oQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:36526 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751935AbbHYLQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 07:16:42 -0400
Received: by oiev193 with SMTP id v193so98362167oie.3
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 04:16:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't know if this was reported before (I'm not subscribed to netdev), but
Google couldn't find it:

lo uses DEPRECATED zero tx_queue_len - convert driver to use
IFF_NO_QUEUE instead

Presumably introduced by
commit 906470c19da771e638e7c8e16e16c31995b139cc
Author: Phil Sutter <phil@nwl.cc>
Date:   Tue Aug 18 10:30:48 2015 +0200

    net: warn if drivers set tx_queue_len = 0

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
