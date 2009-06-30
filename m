From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [7/7] usbnet: Remove private stats structure
Date: Tue, 30 Jun 2009 10:54:12 +0800
Message-ID: <20090630025412.GF14773@gondor.apana.org.au>
References: <200906300045.n5U0j2To004168@rs49.luxsci.com> <20090630024940.GA14707@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, shemminger@vyatta.com,
	"David S. Miller" <davem@davemloft.net>
To: Ben Kibbey <bjk@luxsci.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42781 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755170AbZF3CyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 22:54:13 -0400
Content-Disposition: inline
In-Reply-To: <20090630024940.GA14707@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

usbnet: Remove private stats structure

Now that nothing uses the private stats structure we can remove it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 36fabb9..3b10097 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -42,7 +42,6 @@ struct usbnet {
 
 	/* protocol/interface state */
 	struct net_device	*net;
-	struct net_device_stats	stats;
 	int			msg_enable;
 	unsigned long		data [5];
 	u32			xid;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
