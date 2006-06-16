From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [ETHTOOL]: Fix UFO typo
Date: Fri, 16 Jun 2006 16:39:05 +1000
Message-ID: <20060616063905.GA32669@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bg08WKrSYDhXBjb5"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:11021 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751097AbWFPGjN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 02:39:13 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

[ETHTOOL]: Fix UFO typo

The function ethtool_get_ufo was referring to ETHTOOL_GTSO instead of
ETHTOOL_GUFO.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ufo-typo.patch"

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 3f269e4..151dd98 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -589,7 +589,7 @@ static int ethtool_set_tso(struct net_de
 
 static int ethtool_get_ufo(struct net_device *dev, char __user *useraddr)
 {
-	struct ethtool_value edata = { ETHTOOL_GTSO };
+	struct ethtool_value edata = { ETHTOOL_GUFO };
 
 	if (!dev->ethtool_ops->get_ufo)
 		return -EOPNOTSUPP;
@@ -598,6 +598,7 @@ static int ethtool_get_ufo(struct net_de
 		 return -EFAULT;
 	return 0;
 }
+
 static int ethtool_set_ufo(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_value edata;

--bg08WKrSYDhXBjb5--
