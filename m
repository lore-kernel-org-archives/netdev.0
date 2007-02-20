From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: [PATCH 1/2][IPX] Remove outdated information from Kconfig
Date: Tue, 20 Feb 2007 19:58:08 +0100
Message-ID: <200702201958.09312.eike-kernel@sf-tec.de>
References: <200702201957.13531.eike-kernel@sf-tec.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, linux-kernel@vger.kernel.org,
	acme@conectiva.com.br, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030555AbXBUHYn@vger.kernel.org>
In-Reply-To: <200702201957.13531.eike-kernel@sf-tec.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SPX was removed in early 2.5. How to connect to a Mac or the other OS isn't
hard to find out these days.

Signed-off-by: Rolf Eike Beer <eike-kernel@sf-tec.de>

---
commit 0566e9a5f19ca9fe1982e2b4a89aff131cc6525b
tree 20b72b4e347a0ff926f82188bb296c2b3a8911f5
parent ce4e52a8be675c1724fa3af503ff1c75478ff2e8
author Rolf Eike Beer <eike-kernel@sf-tec.de> Tue, 20 Feb 2007 19:43:37 +0100
committer Rolf Eike Beer <eike-kernel@sf-tec.de> Tue, 20 Feb 2007 19:43:37 +0100

 net/ipx/Kconfig |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/net/ipx/Kconfig b/net/ipx/Kconfig
index 980a826..e9ad006 100644
--- a/net/ipx/Kconfig
+++ b/net/ipx/Kconfig
@@ -16,8 +16,7 @@ config IPX
 	  support", below.
 
 	  IPX is similar in scope to IP, while SPX, which runs on top of IPX,
-	  is similar to TCP. There is also experimental support for SPX in
-	  Linux (see "SPX networking", below).
+	  is similar to TCP.
 
 	  To turn your Linux box into a fully featured NetWare file server and
 	  IPX router, say Y here and fetch either lwared from
@@ -26,9 +25,6 @@ config IPX
 	  information, read the IPX-HOWTO available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-	  General information about how to connect Linux, Windows machines and
-	  Macs is on the WWW at <http://www.eats.com/linux_mac_win.html>.
-
 	  The IPX driver would enlarge your kernel by about 16 KB. To compile
 	  this driver as a module, choose M here: the module will be called ipx.
 	  Unless you want to integrate your Linux box with a local Novell
