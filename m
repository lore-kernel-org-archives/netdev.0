From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: build #307 failed for 2.6.22-g8f41958 in linux/./drivers/net/slip.c
Date: Mon, 16 Jul 2007 12:32:28 +0400
Message-ID: <20070716083228.GA30605@2ka.mipt.ru>
References: <200707161009.59675.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:50683 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754732AbXGPIcf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 04:32:35 -0400
Content-Disposition: inline
In-Reply-To: <200707161009.59675.toralf.foerster@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 16, 2007 at 10:09:56AM +0200, Toralf F=C3=B6rster (toralf.f=
oerster@gmx.de) wrote:
> #
> # Networking
> #
> # CONFIG_NET is not set
> CONFIG_LLC=3Dy
> CONFIG_WIRELESS_EXT=3Dy
> CONFIG_IEEE80211=3Dy
> CONFIG_IEEE80211_CRYPT_WEP=3Dy

This is a result of 'select' usage in Kconfig.
Although this patch can help too.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/net/ieee80211/Kconfig b/net/ieee80211/Kconfig
index 1438ade..a23414f 100644
--- a/net/ieee80211/Kconfig
+++ b/net/ieee80211/Kconfig
@@ -1,5 +1,6 @@
 config IEEE80211
 	tristate "Generic IEEE 802.11 Networking Stack"
+	depends on NET
 	---help---
 	This option enables the hardware independent IEEE 802.11
 	networking stack.

--=20
	Evgeniy Polyakov
