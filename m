From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV4: spelling correction
Date: Wed, 11 Feb 2004 04:03:40 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211.040340.87331331.yoshfuji@linux-ipv6.org>
References: <20040211.033324.120562092.yoshfuji@linux-ipv6.org>
	<402926A0.20809@us.ibm.com>
	<20040210105124.61431b9b.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040210105124.61431b9b.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040210105124.61431b9b.davem@redhat.com> (at Tue, 10 Feb 2004 10:51:24 -0800), "David S. Miller" <davem@redhat.com> says:

> On Tue, 10 Feb 2004 10:44:48 -0800
> Nivedita Singhvi <niv@us.ibm.com> wrote:
> 
> > I strongly object. Strongly and strenuously. DaveM, please,
> > please, please, leave those golden lines alone. The original
> > from Alexey is a work of art, humor, character and intelligence.
> 
> I totally agree.  In documentation and things for end users, fine.
> We can typo correct till the end of time.  But for comments meant
> for programmers, let's keep it lively and humorous and sometimes
> flat out grammatically wrong.  This is what gives it flavor makes
> it our's.

Okay.

But... Please apply the following patch. 
I want to fix my error and mis-leading flags. :-P

Thanks.

===== net/ipv6/addrconf.c 1.91 vs edited =====
--- 1.91/net/ipv6/addrconf.c	Tue Feb  3 03:31:58 2004
+++ edited/net/ipv6/addrconf.c	Wed Feb 11 03:56:59 2004
@@ -1071,7 +1071,7 @@
 		eui[0] ^= 2;
 		return 0;
 	case ARPHRD_ARCNET:
-		/* XXX: inherit EUI-64 fro mother interface -- yoshfuji */
+		/* XXX: inherit EUI-64 from other interface -- yoshfuji */
 		if (dev->addr_len != ARCNET_ALEN)
 			return -1;
 		memset(eui, 0, 7);
===== net/ipv6/ndisc.c 1.71 vs edited =====
--- 1.71/net/ipv6/ndisc.c	Tue Feb 10 04:13:09 2004
+++ edited/net/ipv6/ndisc.c	Wed Feb 11 04:00:28 2004
@@ -747,7 +747,7 @@
 			return;
 		}
 
-		/* XXX: RFC2461 7.1.1:
+		/* RFC2461 7.1.1:
 	 	 *	If the IP source address is the unspecified address, 
 		 *	there MUST NOT be source link-layer address option 
 		 *	in the message.
@@ -1195,7 +1195,7 @@
 		return;
 	}
 
-	/* XXX: RFC2461 8.1: 
+	/* RFC2461 8.1: 
 	 *	The IP source address of the Redirect MUST be the same as the current
 	 *	first-hop router for the specified ICMP Destination Address.
 	 */

--yoshfuji
