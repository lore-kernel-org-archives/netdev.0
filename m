From: Roland Dreier <roland@topspin.com>
Subject: [PATCH][4/3] IPoIB: document conversion to debugfs
Date: Fri, 01 Apr 2005 09:45:33 -0800
Message-ID: <52r7hujsqq.fsf@topspin.com>
References: <20053311936.XaQmN4N9new7dTCP@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	openib-general@openib.org, davem@davemloft.net
Return-path: <openib-general-bounces@openib.org>
To: akpm@osdl.org
In-Reply-To: <20053311936.XaQmN4N9new7dTCP@topspin.com> (Roland Dreier's
	message of "Thu, 31 Mar 2005 19:36:12 -0800")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Update IPoIB documentation now that multicast debugging files have
moved from ipoibdebugfs to debugfs.

Signed-off-by: Roland Dreier <roland@topspin.com>

--- linux-export.orig/Documentation/infiniband/ipoib.txt	2005-03-31 19:07:01.000000000 -0800
+++ linux-export/Documentation/infiniband/ipoib.txt	2005-04-01 09:43:27.122520190 -0800
@@ -32,14 +32,13 @@
   mcast_debug_level to 1.  These parameters can be controlled at
   runtime through files in /sys/module/ib_ipoib/.
 
-  CONFIG_INFINIBAND_IPOIB_DEBUG also enables the "ipoib_debugfs"
+  CONFIG_INFINIBAND_IPOIB_DEBUG also enables files in the debugfs
   virtual filesystem.  By mounting this filesystem, for example with
 
-    mkdir -p /ipoib_debugfs
-    mount -t ipoib_debugfs none /ipoib_debufs
+    mount -t debugfs none /sys/kernel/debug
 
-  it is possible to get statistics about multicast groups from the
-  files /ipoib_debugfs/ib0_mcg and so on.
+  it is possible to get statistics about munlticast groups from the
+  files /sys/kernel/debug/ipoib/ib0_mcg and so on.
 
   The performance impact of this option is negligible, so it
   is safe to enable this option with debug_level set to 0 for normal
