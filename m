From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NETFILTER] Fix comment typo in ip_nat_helper
Date: Tue, 21 Sep 2004 11:35:48 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921013548.GA27679@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="tKW2IUtsqtDRztdT"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        coreteam@netfilter.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

Here's a trivial comment fix that I noticed while tracking down an FTP/NAT
issue.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/netfilter/ip_nat_helper.c 1.22 vs edited =====
--- 1.22/net/ipv4/netfilter/ip_nat_helper.c	2004-08-26 13:19:30 +10:00
+++ edited/net/ipv4/netfilter/ip_nat_helper.c	2004-09-21 11:14:52 +10:00
@@ -73,7 +73,7 @@
 
 	LOCK_BH(&ip_nat_seqofs_lock);
 
-	/* SYN adjust. If it's uninitialized, of this is after last
+	/* SYN adjust. If it's uninitialized, or this is after last
 	 * correction, record it: we don't handle more than one
 	 * adjustment in the window, but do deal with common case of a
 	 * retransmit */

--tKW2IUtsqtDRztdT--
