From: Richard Cochran <richardcochran@gmail.com>
Subject: net-next compilation failure since 76ff5cc9
Date: Sun, 22 Jul 2012 18:21:07 +0200
Message-ID: <20120722162107.GA23219@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:53400 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017Ab2GVQVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 12:21:17 -0400
Received: by weyx8 with SMTP id x8so3735755wey.19
        for <netdev@vger.kernel.org>; Sun, 22 Jul 2012 09:21:15 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without CONFIG_RPS, net-next fails to compile with

  CC      net/core/rtnetlink.o
/linux/net/core/rtnetlink.c: In function =E2=80=98rtnl_fill_ifinfo=E2=80=
=99:
/linux/net/core/rtnetlink.c:895: error: =E2=80=98struct net_device=E2=80=
=99 has no member named =E2=80=98num_rx_queues=E2=80=99
make[3]: *** [net/core/rtnetlink.o] Error 1

Looks like this was caused by

76ff5cc9  rtnl: allow to specify number of rx and tx queues on device c=
reation

Not sure how to fix.

Thanks,
Richard
