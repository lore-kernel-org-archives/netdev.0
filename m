From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [BUG] linux >= 2.6.5 won't compile with CONFIG_IPV6=m and CONFIG_IP6_NF_QUEUE=y
Date: Mon, 19 Apr 2004 21:12:38 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040419111238.GA23696@gondor.apana.org.au>
References: <20040419011418.42b6f4e9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="6c2NcOVqGQ03X4Wi"
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040419011418.42b6f4e9.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--6c2NcOVqGQ03X4Wi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Apr 19, 2004 at 08:14:18AM +0000, Andrew Morton wrote:

> Subject: [BUG] linux >= 2.6.5 won't compile with CONFIG_IPV6=m and CONFIG_IP6_NF_QUEUE=y

This patch should stop this from happening.
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--6c2NcOVqGQ03X4Wi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

Index: net/ipv6/netfilter/Kconfig
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/ipv6/netfilter/Kconfig,v
retrieving revision 1.1.1.5
diff -u -r1.1.1.5 Kconfig
--- a/net/ipv6/netfilter/Kconfig	19 Feb 2004 08:56:07 -0000	1.1.1.5
+++ b/net/ipv6/netfilter/Kconfig	19 Apr 2004 11:08:21 -0000
@@ -3,7 +3,7 @@
 #
 
 menu "IPv6: Netfilter Configuration"
-	depends on INET && IPV6!=n && NETFILTER
+	depends on INET && IPV6 && NETFILTER
 
 #tristate 'Connection tracking (required for masq/NAT)' CONFIG_IP6_NF_CONNTRACK
 #if [ "$CONFIG_IP6_NF_CONNTRACK" != "n" ]; then

--6c2NcOVqGQ03X4Wi--
