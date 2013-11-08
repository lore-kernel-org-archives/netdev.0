From: =?UTF-8?q?Petr=20=C5=A0abata?= <contyk@redhat.com>
Subject: [PATCH] iproute2: Document type vlan option in ip-link(8)
Date: Fri,  8 Nov 2013 12:54:31 +0900
Message-ID: <1383882871-7632-1-git-send-email-contyk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Petr=20=C5=A0abata?= <contyk@redhat.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47687 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752935Ab3KHDyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 22:54:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the VLAN Type support section to the ip-link
manual page.

Signed-off-by: Petr =C5=A0abata <contyk@redhat.com>
---
 man/man8/ip-link.8.in | 59 +++++++++++++++++++++++++++++++++++++++++++=
++++++++
 1 file changed, 59 insertions(+)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 8b68c78..4eddbcd 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -213,6 +213,65 @@ specifies the number of transmit queues for new de=
vice.
 specifies the number of receive queues for new device.
=20
 .TP
+VLAN Type Support
+For a link of type
+.I VLAN
+the following additional arguments are supported:
+
+.BI "ip link add link " DEVICE
+.BI name " NAME "
+.BI type " vlan "
+.R " [ "
+.BI protocol " VLAN_PROTO "
+.R " ] "
+.BI id " VLANID "
+.R " [ "
+.BR reorder_hdr " { " on " | " off " } "
+.R " ] "
+.R " [ "
+.BR gvrp " { " on " | " off " } "
+.R " ] "
+.R " [ "
+.BR mvrp " { " on " | " off " } "
+.R " ] "
+.R " [ "
+.BR loose_binding " { " on " | " off " } "
+.R " ] "
+.R " [ "
+.BI ingress-qos-map " QOS-MAP "
+.R " ] "
+.R " [ "
+.BI egress-qos-map " QOS-MAP "
+.R " ] "
+
+.in +8
+.sp
+.BI protocol " VLAN_PROTO "
+- either 802.1Q or 802.1ad.
+
+.BI id " VLANID "
+- specifies the VID.
+
+.BR reorder_hdr " { " on " | " off " } "
+- specifies whether ethernet headers are reordered or not.
+
+.BR gvrp " { " on " | " off " } "
+- specifies whether this VLAN should be registered using GARP VLAN Reg=
istration Protocol.
+
+.BR mvrp " { " on " | " off " } "
+- specifies whether this VLAN should be registered using Multiple VLAN=
 Registration Protocol.
+
+.BR loose_binding " { " on " | " off " } "
+- specifies whether the VLAN device state is bound to the physical dev=
ice state.
+
+.BI ingress-qos-map " QOS-MAP "
+- defines a mapping between priority code points on incoming frames.  =
The format is FROM:TO with multiple mappings separated by spaces.
+
+.BI egress-qos-map " QOS-MAP "
+- the same as ingress-qos-map but for outgoing frames.
+.in -8
+
+.TP
 VXLAN Type Support
 For a link of type=20
 .I VXLAN
--=20
1.8.3.1
