From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH] Phonet: resource routing documentation
Date: Thu, 16 Sep 2010 01:30:15 +0300
Message-ID: <1284589815-28302-5-git-send-email-remi@remlab.net>
References: <d214bd6716258777ce8b1023208bc347@chewa.net>
 <1284589815-28302-1-git-send-email-remi@remlab.net>
 <1284589815-28302-2-git-send-email-remi@remlab.net>
 <1284589815-28302-3-git-send-email-remi@remlab.net>
 <1284589815-28302-4-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:36525 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753483Ab0IOWaR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 18:30:17 -0400
In-Reply-To: <1284589815-28302-4-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 Documentation/networking/phonet.txt |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/phonet.txt b/Documentation/networ=
king/phonet.txt
index 6e8ce09..cf76608 100644
--- a/Documentation/networking/phonet.txt
+++ b/Documentation/networking/phonet.txt
@@ -112,6 +112,22 @@ However, connect() and getpeername() are not suppo=
rted, as they did
 not seem useful with Phonet usages (could be added easily).
=20
=20
+Resource subscription
+---------------------
+
+A Phonet datagram socket can be subscribed to any number of 8-bits
+Phonet resources, as follow:
+
+  uint32_t res =3D 0xXX;
+  ioctl(fd, SIOCPNADDRESOURCE, &res);
+
+Subscription is similarly cancelled using the SIOCPNDELRESOURCE I/O
+control request, or when the socket is closed.
+
+Note that no more than one socket can be subcribed to any given
+resource at a time. If not, ioctl() will return EBUSY.
+
+
 Phonet Pipe protocol
 --------------------
=20
--=20
1.7.0.4

