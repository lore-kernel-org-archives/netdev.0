From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Wed, 30 Jul 2008 22:48:49 +0200
Message-ID: <20080730224849.59852c68@surf>
References: <200807301939.m6UJd5lT012610@imap1.linux-foundation.org>
	<20080730133727.7774de6a@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	davem@davemloft.net, mpm@selenic.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.191.46.45]:40766 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbYG3Usz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 16:48:55 -0400
In-Reply-To: <20080730133727.7774de6a@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Wed, 30 Jul 2008 13:37:27 -0700,
Stephen Hemminger <shemminger@vyatta.com> a =C3=A9crit :

> This option needs to be forced on when bridging or bonding is
> selected.

Do you mean something like the following fixup patch ?

Thanks,

Thomas

Make sure ETHTOOL support is selected when bonding and bridging are
requested.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

---
 drivers/net/Kconfig |    1 +
 net/bridge/Kconfig  |    1 +
 2 files changed, 2 insertions(+)

Index: linuxdev/drivers/net/Kconfig
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linuxdev.orig/drivers/net/Kconfig
+++ linuxdev/drivers/net/Kconfig
@@ -61,6 +61,7 @@
 config BONDING
 	tristate "Bonding driver support"
 	depends on INET
+	select ETHTOOL
 	---help---
 	  Say 'Y' or 'M' if you wish to be able to 'bond' multiple Ethernet
 	  Channels together. This is called 'Etherchannel' by Cisco,
Index: linuxdev/net/bridge/Kconfig
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linuxdev.orig/net/bridge/Kconfig
+++ linuxdev/net/bridge/Kconfig
@@ -6,6 +6,7 @@
 	tristate "802.1d Ethernet Bridging"
 	select LLC
 	select STP
+	select ETHTOOL
 	---help---
 	  If you say Y here, then your Linux box will be able to act as an
 	  Ethernet bridge, which means that the different Ethernet segments i=
t


--=20
Thomas Petazzoni, Free Electrons
Kernel, drivers and embedded Linux development,
consulting, training and support.
http://free-electrons.com
