From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make struct ipv4_devconf static
Date: Wed, 30 Jan 2008 22:02:54 +0200
Message-ID: <20080130200254.GC29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:51776 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755784AbYA3UCU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 15:02:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct ipv4_devconf can now become static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 include/linux/inetdevice.h |    2 --
 net/ipv4/devinet.c         |    2 +-
 2 files changed, 1 insertion(+), 3 deletions(-)

20262a3317069b1bdbf2b37f4002fa5322445914 
diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 8d9eaae..fc4e3db 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -17,8 +17,6 @@ struct ipv4_devconf
 	DECLARE_BITMAP(state, __NET_IPV4_CONF_MAX - 1);
 };
 
-extern struct ipv4_devconf ipv4_devconf;
-
 struct in_device
 {
 	struct net_device	*dev;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 21f71bf..5ab5acc 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -64,7 +64,7 @@
 #include <net/rtnetlink.h>
 #include <net/net_namespace.h>
 
-struct ipv4_devconf ipv4_devconf = {
+static struct ipv4_devconf ipv4_devconf = {
 	.data = {
 		[NET_IPV4_CONF_ACCEPT_REDIRECTS - 1] = 1,
 		[NET_IPV4_CONF_SEND_REDIRECTS - 1] = 1,

