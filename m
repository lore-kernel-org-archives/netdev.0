From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] IPV6: note on shared socket options
Date: Wed, 4 Feb 2004 13:49:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF2F9C078B.064A8A19-ON87256E30.0077B005-88256E30.0077AF76@us.ibm.com>
References: <20040204.203739.16838230.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=08BBE4A3DFE436958f9e8a93df938690918c08BBE4A3DFE43695"
Cc: davem@redhat.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040204.203739.16838230.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=08BBE4A3DFE436958f9e8a93df938690918c08BBE4A3DFE43695
Content-type: text/plain; charset=ISO-2022-JP





Yoshifuji-san,
      These are defined by draft-ietf-magma-msf-api-03.txt to be in
netinet/in.h (no place else). What's the advantage of adding another
copy in in6.h (which currently isn't used by anything)? Portable user apps
must include netinet/in.h for them, and in-kernel code already does.

                        +-DLS


YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>@oss.sgi.com on
02/04/2004 03:37:39 AM

Sent by:    netdev-bounce@oss.sgi.com


To:    davem@redhat.com
cc:    yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Subject:    [PATCH] IPV6: note on shared socket options



Hello.

There're several socket options for multicast
shared between IPv4 and IPv6.
Add a note that some range is already used for them.

(Alternatevely, we could define other names like this:
 #define IPV6_MCAST_JOIN_GROUP   MCAST_JOIN_GROUP
 #define IPV6_MCAST_BLOCK_SOURCE MCAST_BLOCK_SOURCE
 /* bla, bla ... */
)

===== include/linux/in6.h 1.5 vs edited =====
--- 1.5/include/linux/in6.h   Fri Mar 21 14:23:30 2003
+++ edited/include/linux/in6.h      Wed Feb  4 20:30:47 2004
@@ -183,5 +183,17 @@
 #define IPV6_IPSEC_POLICY    34
 #define IPV6_XFRM_POLICY     35

+/*
+ * Multicast:
+ * Following socket options are shared between IPv4 and IPv6.
+ *
+ * MCAST_JOIN_GROUP          42
+ * MCAST_BLOCK_SOURCE        43
+ * MCAST_UNBLOCK_SOURCE            44
+ * MCAST_LEAVE_GROUP         45
+ * MCAST_JOIN_SOURCE_GROUP   46
+ * MCAST_LEAVE_SOURCE_GROUP  47
+ * MCAST_MSFILTER            48
+ */

 #endif

--
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

--0__=08BBE4A3DFE436958f9e8a93df938690918c08BBE4A3DFE43695
Content-type: text/html; charset=ISO-2022-JP
Content-Disposition: inline

<html><body>
<p>Yoshifuji-san,<br>
	These are defined by draft-ietf-magma-msf-api-03.txt to be in<br>
netinet/in.h (no place else). What's the advantage of adding another<br>
copy in in6.h (which currently isn't used by anything)? Portable user apps<br>
must include netinet/in.h for them, and in-kernel code already does.<br>
<br>
				+-DLS<br>
<br>

<p><font size="2" color="#800080">Sent by:	netdev-bounce@oss.sgi.com</font>
<p><font size="2" color="#800080">To:	</font><font size="2">davem@redhat.com</font><br>
<font size="2" color="#800080">cc:	</font><font size="2">yoshfuji@linux-ipv6.org, netdev@oss.sgi.com</font><font size="2" color="#800080"> </font><br>
<font size="2" color="#800080">Subject:	</font><font size="2">[PATCH] IPV6: note on shared socket options</font><br>
<br>
<br>
<br>
<tt>Hello.<br>
</tt><br>
<tt>There're several socket options for multicast<br>
shared between IPv4 and IPv6.<br>
Add a note that some range is already used for them.<br>
</tt><br>
<tt>(Alternatevely, we could define other names like this:<br>
#define IPV6_MCAST_JOIN_GROUP &nbsp; MCAST_JOIN_GROUP<br>
#define IPV6_MCAST_BLOCK_SOURCE MCAST_BLOCK_SOURCE<br>
/* bla, bla ... */</tt><br>
<tt>)<br>
</tt><br>
<tt>===== include/linux/in6.h 1.5 vs edited =====<br>
--- 1.5/include/linux/in6.h	Fri Mar 21 14:23:30 2003<br>
+++ edited/include/linux/in6.h	Wed Feb &nbsp;4 20:30:47 2004<br>
@@ -183,5 +183,17 @@</tt><br>
<tt>#define IPV6_IPSEC_POLICY	34<br>
#define IPV6_XFRM_POLICY	35</tt><br>
<br>
<tt>+/*<br>
+ * Multicast:<br>
+ * Following socket options are shared between IPv4 and IPv6.<br>
+ *<br>
+ * MCAST_JOIN_GROUP		42<br>
+ * MCAST_BLOCK_SOURCE		43<br>
+ * MCAST_UNBLOCK_SOURCE		44<br>
+ * MCAST_LEAVE_GROUP		45<br>
+ * MCAST_JOIN_SOURCE_GROUP	46<br>
+ * MCAST_LEAVE_SOURCE_GROUP	47<br>
+ * MCAST_MSFILTER		48<br>
+ */<br>
</tt><br>
<tt>#endif<br>
</tt><br>
<tt>--<br>
Hideaki YOSHIFUJI @ USAGI Project &lt;yoshfuji@linux-ipv6.org&gt;<br>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF &nbsp;80D8 4807 F894 E062 0EEA</tt><br>
<br>
</body></html>
--0__=08BBE4A3DFE436958f9e8a93df938690918c08BBE4A3DFE43695--
