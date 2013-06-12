From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v2 net-next 1/3] net: remove NET_LL_RX_POLL
	config menue
Date: Wed, 12 Jun 2013 14:19:55 +0300
Message-ID: <20130612111955.19288.12053.stgit@ladj378.jer.intel.com>
References: <20130612111942.19288.12131.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Kehati <ork@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Amir Vadai <amirv@mellanox.com>,
	linux-kernel@vger.kernel.org, Alex Rosenbaum <alexr@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Eliezer Tamir <eliezer@tamir.org.il>,
	Avner Ben Hanoch <avnerb@mellanox.com>, Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <erdnetdev@gmail.com>, Eilon Greenstien <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130612111942.19288.12131.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Remove NET_LL_RX_POLL from the config menu.
Change default to y.
Busy polling still needs to be enabled at run time.

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 net/Kconfig |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/net/Kconfig b/net/Kconfig
index d6a9ce6..8fe8845 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -244,16 +244,9 @@ config NETPRIO_CGROUP
 	  a per-interface basis
 
 config NET_LL_RX_POLL
-	bool "Low Latency Receive Poll"
+	boolean
 	depends on X86_TSC
-	default n
-	---help---
-	  Support Low Latency Receive Queue Poll.
-	  (For network card drivers which support this option.)
-	  When waiting for data in read or poll call directly into the the device driver
-	  to flush packets which may be pending on the device queues into the stack.
-
-	  If unsure, say N.
+	default y
 
 config BQL
 	boolean


------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
