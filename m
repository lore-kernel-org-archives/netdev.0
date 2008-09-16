From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 00/14] [RFC] Phonet protocol stack
Date: Tue, 16 Sep 2008 17:57:38 +0300
Message-ID: <200809161757.38571.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:43132 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782AbYIPO6U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 10:58:20 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8GEw3vE022593
	for <netdev@vger.kernel.org>; Tue, 16 Sep 2008 17:58:18 +0300
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

This patch series introduces support for PhoNet,
the "Phone Network protocol". This protocol is the primary interface
to Nokia cellular modem engines. We are integrating it to the Linux
kernel in order to support HSPA cellular data connectivity on the
Maemo Software platform.

This patchset provides a simple datagram socket=20
independent of the underlying hardware (network interface) through
which the modem is attached. We are in the process of contributing
a lower-layer driver through Linux OMAP.

This series is based on net-next-2.6, plus the tiny MISDN lockdep fix
I posted to netdev yesterday.

Any comments welcome.

--
 Documentation/networking/phonet.txt |  111 ++++++++
 include/linux/if_ether.h            |    1
 include/linux/if_phonet.h           |   16 +
 include/linux/phonet.h              |  136 ++++++++++
 include/linux/rtnetlink.h           |    4
 include/linux/socket.h              |    4
 include/net/phonet/phonet.h         |  103 +++++++
 include/net/phonet/pn_dev.h         |   63 ++++
 net/Kconfig                         |    1
 net/Makefile                        |    1
 net/core/sock.c                     |    9
 net/phonet/Kconfig                  |   11
 net/phonet/Makefile                 |   11
 net/phonet/af_phonet.c              |  485 +++++++++++++++++++++++++++=
++++++++-
 net/phonet/datagram.c               |  197 ++++++++++++++
 net/phonet/pn_dev.c                 |  232 +++++++++++++++++
 net/phonet/pn_netlink.c             |  239 +++++++++++++++++
 net/phonet/socket.c                 |  314 +++++++++++++++++++++++
 net/phonet/sysctl.c                 |  111 ++++++++
 19 files changed, 2036 insertions(+), 13 deletions(-)

Regards,

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
