From: Jamal Hadi Salim <hadi@znyx.com>
Subject: 2.4.x patchlet
Date: 28 Dec 2004 09:04:45 -0500
Message-ID: <1104242685.1090.97.camel@jzny.localdomain>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-gDswNaKcgwzQsr1L9zpL"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-gDswNaKcgwzQsr1L9zpL
Content-Transfer-Encoding: 7bit
Content-Type: text/plain


Removes annoying compile of newer tools when done on 2.4.x

cheers,
jamal

--=-gDswNaKcgwzQsr1L9zpL
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=arp-eth-patchlet
Content-Type: text/plain; name=arp-eth-patchlet; charset=ISO-8859-1

--- 2429-pre3/include/linux/if_ether.h	2003-08-25 07:44:44.000000000 -0400
+++ 2429-pre3-bk1/include/linux/if_ether.h	2004-12-27 10:51:46.000000000 -0500
@@ -61,6 +61,8 @@
 #define ETH_P_IPV6	0x86DD		/* IPv6 over bluebook		*/
 #define ETH_P_PPP_DISC	0x8863		/* PPPoE discovery messages     */
 #define ETH_P_PPP_SES	0x8864		/* PPPoE session messages	*/
+#define ETH_P_MPLS_UC	0x8847		/* MPLS Unicast traffic         */
+#define ETH_P_MPLS_MC	0x8848		/* MPLS Multicast traffic       */
 #define ETH_P_ATMMPOA	0x884c		/* MultiProtocol Over ATM	*/
 #define ETH_P_ATMFATE	0x8884		/* Frame-based ATM Transport
 					 * over Ethernet
--- 2429-pre3/include/linux/if_arp.h	2004-08-07 19:26:06.000000000 -0400
+++ 2429-pre3-bk1/include/linux/if_arp.h	2004-12-27 11:30:20.000000000 -0500
@@ -40,6 +40,7 @@
 #define ARPHRD_METRICOM	23		/* Metricom STRIP (new IANA id)	*/
 #define	ARPHRD_IEEE1394	24		/* IEEE 1394 IPv4 - RFC 2734	*/
 #define ARPHRD_EUI64	27		/* EUI-64                       */
+#define ARPHRD_INFINIBAND	32		/* InfiniBand                   */
 
 /* Dummy types for non ARP hardware */
 #define ARPHRD_SLIP	256

--=-gDswNaKcgwzQsr1L9zpL--
