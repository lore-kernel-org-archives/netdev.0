From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 6/6] [6LoWPAN] update documentation
Date: Wed,  2 Nov 2011 19:35:54 +0300
Message-ID: <1320251754-2971-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111102162520.GA2669@avtobot.cybertron>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20111102162520.GA2669-AUGNqIMGY+bGcXpsla5Oef8+0UxHXcjY@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds chapter to documentation which describes how to use
6lowpan technology.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 Documentation/networking/ieee802154.txt |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/ieee802154.txt b/Documentation/networking/ieee802154.txt
index 23c995e..7d50b26 100644
--- a/Documentation/networking/ieee802154.txt
+++ b/Documentation/networking/ieee802154.txt
@@ -78,3 +78,29 @@ in software. This is currently WIP.
 
 See header include/net/mac802154.h and several drivers in drivers/ieee802154/.
 
+6LoWPAN Linux implementation
+============================
+
+The IEEE 802.15.4 standard specifies an MTU of 128 bytes, yielding about 80
+octets of actual MAC payload once security is turned on, on a wireless link
+with a link throughput of 250 kbps or less.  The 6LoWPAN adaptation format
+[RFC4944] was specified to carry IPv6 datagrams over such constrained links,
+taking into account limited bandwidth, memory, or energy resources that are
+expected in applications such as wireless Sensor Networks.  [RFC4944] defines
+a Mesh Addressing header to support sub-IP forwarding, a Fragmentation header
+to support the IPv6 minimum MTU requirement [RFC2460], and stateless header
+compression for IPv6 datagrams (LOWPAN_HC1 and LOWPAN_HC2) to reduce the
+relatively large IPv6 and UDP headers down to (in the best case) several bytes.
+
+All the code related to 6lowpan you may find in files: net/ieee802154/6lowpan.*
+
+To setup 6lowpan interface you need:
+1. Add IEEE802.15.4 interface and initialize PANid;
+2. Add 6lowpan interface by command like:
+   # ip link add link wpan0 name lowpan0 type lowpan
+3. Set MAC (if needs):
+   # ip link set lowpan0 address de:ad:be:ef:ca:fe:ba:be
+4. Bring up 'lowpan0' interface
+
+
+
-- 
1.7.2.5


------------------------------------------------------------------------------
RSA&#174; Conference 2012
Save $700 by Nov 18
Register now&#33;
http://p.sf.net/sfu/rsa-sfdev2dev1
