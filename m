From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: build #307 failed for 2.6.22-g8f41958 in linux/./drivers/net/slip.c
Date: Mon, 16 Jul 2007 13:47:36 +0400
Message-ID: <20070716094735.GA10334@2ka.mipt.ru>
References: <200707161009.59675.toralf.foerster@gmx.de> <20070716083228.GA30605@2ka.mipt.ru> <200707161136.24332.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:38751 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757016AbXGPJrn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 05:47:43 -0400
Content-Disposition: inline
In-Reply-To: <200707161136.24332.toralf.foerster@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 16, 2007 at 11:36:19AM +0200, Toralf F=C3=B6rster (toralf.f=
oerster@gmx.de) wrote:
> Am Montag, 16. Juli 2007 10:32 schrieb Evgeniy Polyakov:
> > This is a result of 'select' usage in Kconfig.
> > Although this patch can help too.
> >
>=20
> Hi,
> unfortunatly the patch doesn't help :

It does not help with llc because of select usage.
Netdevices likely should also depend on net.

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ba314ad..c2ab077 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -4,6 +4,7 @@
 #
=20
 menuconfig NETDEVICES
+	depends on NET
 	default y if UML
 	bool "Network device support"
 	---help---


--=20
	Evgeniy Polyakov
