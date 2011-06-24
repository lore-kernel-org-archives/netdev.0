From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH NET-NEXT] net: Kill unuseful net/TUNABLE doc in kernel source
Date: Fri, 24 Jun 2011 15:53:48 +0800
Message-ID: <4E04428C.9080703@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60572 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751778Ab1FXHwt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2011 03:52:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

File net/TUNABLE has never be updated since git age.

For some tunable parameters which user can control with proc file-system,
They are all in ip-sysctl.txt doc.

For tunable parameters that only at compile time, no meaning to note them.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/TUNABLE |   50 --------------------------------------------------
 1 files changed, 0 insertions(+), 50 deletions(-)
 delete mode 100644 net/TUNABLE

diff --git a/net/TUNABLE b/net/TUNABLE
deleted file mode 100644
index 9913211..0000000
--- a/net/TUNABLE
+++ /dev/null
@@ -1,50 +0,0 @@
-The following parameters should be tunable at compile time. Some of them
-exist as sysctls too.
-
-This is far from complete
-
-Item			Description
-----------------------------------------------------------------------------
-MAX_LINKS		Maximum number of netlink minor devices. (1-32)
-RIF_TABLE_SIZE		Token ring RIF cache size (tunable)
-AARP_HASH_SIZE		Size of Appletalk hash table (tunable)
-AX25_DEF_T1		AX.25 parameters. These are all tunable via
-AX25_DEF_T2		SIOCAX25SETPARMS
-AX25_DEF_T3		T1-T3,N2 have the meanings in the specification
-AX25_DEF_N2
-AX25_DEF_AXDEFMODE	8 = normal 128 is PE1CHL extended
-AX25_DEF_IPDEFMODE	'D' - datagram  'V' - virtual connection
-AX25_DEF_BACKOFF	'E'xponential 'L'inear
-AX25_DEF_NETROM		Allow netrom 1=Y
-AX25_DF_TEXT		Allow PID=Text 1=Y
-AX25_DEF_WINDOW		Window for normal mode
-AX25_DEF_EWINDOW	Window for PE1CHL mode
-AX25_DEF_DIGI		1 for inband 2 for cross band 3 for both
-AX25_DEF_CONMODE	Allow connected modes 1=Yes
-AX25_ROUTE_MAX		AX.25 route cache size - no currently tunable
-Unnamed (16)		Number of protocol hash slots (tunable)
-DEV_NUMBUFFS		Number of priority levels (not easily tunable)
-Unnamed (300)		Maximum packet backlog queue (tunable)
-MAX_IOVEC		Maximum number of iovecs in a message (tunable)
-MIN_WINDOW		Offered minimum window (tunable)
-MAX_WINDOW		Offered maximum window (tunable)
-MAX_HEADER		Largest physical header (tunable)
-MAX_ADDR_LEN		Largest physical address (tunable)
-SOCK_ARRAY_SIZE		IP socket array hash size (tunable)
-IP_MAX_MEMBERSHIPS	Largest number of groups per socket (BSD style) (tunable)
-16			Hard coded constant for amount of room allowed for
-			cache align and faster forwarding (tunable)
-IP_FRAG_TIME		Time we hold a fragment for. (tunable)
-PORT_MASQ_BEGIN		First port reserved for masquerade (tunable)
-PORT_MASQ_END		Last port used for masquerade	(tunable)
-MASQUERADE_EXPIRE_TCP_FIN	Time we keep a masquerade for after a FIN
-MASQUERADE_EXPIRE_UDP	Time we keep a UDP masquerade for (tunable)
-MAXVIFS			Maximum mrouted vifs (1-32)
-MFC_LINES		Lines in the multicast router cache (tunable)
-
-NetROM parameters are tunable via an ioctl passing a struct
-
-4000			Size a Unix domain socket malloc falls back to 
-			(tunable) should be 8K - a bit for 8K machines like
-			the ALPHA
-
-- 
1.7.4.1
