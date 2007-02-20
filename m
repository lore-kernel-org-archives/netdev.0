From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: [PATCH 2/2][IPX] Remove ancient changelog
Date: Tue, 20 Feb 2007 19:59:34 +0100
Message-ID: <200702201959.35176.eike-kernel@sf-tec.de>
References: <200702201957.13531.eike-kernel@sf-tec.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, linux-kernel@vger.kernel.org,
	acme@conectiva.com.br, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030570AbXBUHZQ@vger.kernel.org>
In-Reply-To: <200702201957.13531.eike-kernel@sf-tec.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPX] Remove ancient changelog

Signed-off-by: Rolf Eike Beer <eike-kernel@sf-tec.de>

---
commit 6b8afc66b9d6893d3fa292b75769b58539836ff3
tree 9078513bb6727e61aee238da153d9b3358a1d817
parent 0566e9a5f19ca9fe1982e2b4a89aff131cc6525b
author Rolf Eike Beer <eike-kernel@sf-tec.de> Tue, 20 Feb 2007 19:45:03 +0100
committer Rolf Eike Beer <eike-kernel@sf-tec.de> Tue, 20 Feb 2007 19:45:03 +0100

 net/ipx/ChangeLog |  101 -----------------------------------------------------
 1 files changed, 0 insertions(+), 101 deletions(-)

diff --git a/net/ipx/ChangeLog b/net/ipx/ChangeLog
deleted file mode 100644
index 3b29763..0000000
--- a/net/ipx/ChangeLog
+++ /dev/null
@@ -1,101 +0,0 @@
- Revision 0.21:	Uses the new generic socket option code.
-
- Revision 0.22:	Gcc clean ups and drop out device registration. Use the
- 		new multi-protocol edition of hard_header
-
- Revision 0.23: IPX /proc by Mark Evans. Adding a route will
- 		will overwrite any existing route to the same network.
-
- Revision 0.24:	Supports new /proc with no 4K limit
-
- Revision 0.25:	Add ephemeral sockets, passive local network
- 		identification, support for local net 0 and
- 		multiple datalinks <Greg Page>
-
- Revision 0.26: Device drop kills IPX routes via it. (needed for module)
-
- Revision 0.27: Autobind <Mark Evans>
-
- Revision 0.28: Small fix for multiple local networks <Thomas Winder>
-
- Revision 0.29: Assorted major errors removed <Mark Evans>
- 		Small correction to promisc mode error fix <Alan Cox>
- 		Asynchronous I/O support. Changed to use notifiers
- 		and the newer packet_type stuff. Assorted major
- 		fixes <Alejandro Liu>
-
- Revision 0.30:	Moved to net/ipx/...	<Alan Cox>
- 		Don't set address length on recvfrom that errors.
- 		Incorrect verify_area.
-
- Revision 0.31:	New sk_buffs. This still needs a lot of 
- 		testing. <Alan Cox>
-
- Revision 0.32: Using sock_alloc_send_skb, firewall hooks. <Alan Cox>
- 		Supports sendmsg/recvmsg
-
- Revision 0.33:	Internal network support, routing changes, uses a
- 		protocol private area for ipx data.
-
- Revision 0.34:	Module support. <Jim Freeman>
-
- Revision 0.35: Checksum support. <Neil Turton>, hooked in by <Alan Cox>
- 		Handles WIN95 discovery packets <Volker Lendecke>
-
- Revision 0.36:	Internal bump up for 2.1
-
- Revision 0.37:	Began adding POSIXisms.
-
- Revision 0.38: Asynchronous socket stuff made current.
-
- Revision 0.39: SPX interfaces
-
- Revision 0.40: Tiny SIOCGSTAMP fix (chris@cybernet.co.nz)
-
- Revision 0.41: 802.2TR removed (p.norton@computer.org)
- 		Fixed connecting to primary net,
- 		Automatic binding on send & receive,
- 		Martijn van Oosterhout <kleptogimp@geocities.com>
-
- Revision 042:  Multithreading - use spinlocks and refcounting to
- 		protect some structures: ipx_interface sock list, list
- 		of ipx interfaces, etc. 
- 		Bugfixes - do refcounting on net_devices, check function
- 		results, etc. Thanks to davem and freitag for
- 		suggestions and guidance.
- 		Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
- 		November, 2000
-
- Revision 043:	Shared SKBs, don't mangle packets, some cleanups
- 		Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
- 		December, 2000
-
- Revision 044:	Call ipxitf_hold on NETDEV_UP - acme
-
- Revision 045:	fix PPROP routing bug - acme
-
- Revision 046:	Further fixes to PPROP, ipxitf_create_internal was
- 		doing an unneeded MOD_INC_USE_COUNT, implement
- 		sysctl for ipx_pprop_broacasting, fix the ipx sysctl
- 		handling, making it dynamic, some cleanups, thanks to
- 		Petr Vandrovec for review and good suggestions. (acme)
-
- Revision 047:	Cleanups, CodingStyle changes, move the ncp connection
- 		hack out of line - acme
-
- Revision 048:	Use sk->protinfo to store the pointer to IPX private
- 		area, remove af_ipx from sk->protinfo and move ipx_opt
- 		to include/net/ipx.h, use IPX_SK like DecNET, etc - acme
-
- Revision 049:	SPX support dropped, see comment in ipx_create - acme
-
- Revision 050:	Use seq_file for proc stuff, moving it to ipx_proc.c - acme
-
-Other fixes:
- 
- Protect the module by a MOD_INC_USE_COUNT/MOD_DEC_USE_COUNT pair. Also, now
- usage count is managed this way:
- -Count one if the auto_interface mode is on
- -Count one per configured interface
- 
- Jacques Gelinas (jacques@solucorp.qc.ca)
