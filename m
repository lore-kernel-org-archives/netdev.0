From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NETDRV] Fix netdev leak on probe failure in 3c527
Date: Sat, 5 Jun 2004 17:55:15 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040605075515.GA28723@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="azLHFNyN32YCQGCU"
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Jeff:

This patch frees the netdev on failure in mc32_probe in 3c527.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== drivers/net/3c527.c 1.23 vs edited =====
--- 1.23/drivers/net/3c527.c	2004-05-22 17:28:45 +10:00
+++ edited/drivers/net/3c527.c	2004-06-05 17:51:23 +10:00
@@ -287,6 +287,7 @@
 			
 		}
 	}
+	free_netdev(dev);
 	return ERR_PTR(-ENODEV);
 }
 

--azLHFNyN32YCQGCU--
