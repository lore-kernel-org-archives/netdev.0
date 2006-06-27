From: paul.moore@hp.com
Subject: [RFC 8/8] NetLabel: tie NetLabel into the Kconfig
	system
Date: Tue, 27 Jun 2006 18:56:39 -0400
Message-ID: <20060627230053.611591000@flek.zko.hp.com>
References: <20060627225631.538814000@flek.zko.hp.com>
Cc: sgrubb@redhat.com, pratt@argus-systems.com
Return-path: <redhat-lspp-bounces@redhat.com>
To: redhat-lspp@redhat.com, netdev@vger.kernel.org
Content-Disposition: inline; filename=netlabel-net_kconfig-2.6.17
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/redhat-lspp>,
	<mailto:redhat-lspp-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/redhat-lspp>
List-Post: <mailto:redhat-lspp@redhat.com>
List-Help: <mailto:redhat-lspp-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/redhat-lspp>,
	<mailto:redhat-lspp-request@redhat.com?subject=subscribe>
Sender: redhat-lspp-bounces@redhat.com
Errors-To: redhat-lspp-bounces@redhat.com
List-Id: netdev.vger.kernel.org

Modify the net/Kconfig file to enable selecting the NetLabel Kconfig options.
---
 net/Kconfig |    2 ++
 1 files changed, 2 insertions(+)

Index: linux-2.6.17.i686-quilt/net/Kconfig
===================================================================
--- linux-2.6.17.i686-quilt.orig/net/Kconfig
+++ linux-2.6.17.i686-quilt/net/Kconfig
@@ -228,6 +228,8 @@ source "net/tux/Kconfig"
 config WIRELESS_EXT
 	bool
 
+source "net/netlabel/Kconfig"
+
 endif   # if NET
 endmenu # Networking
 

--
paul moore
linux security @ hp
