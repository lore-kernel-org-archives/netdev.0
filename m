From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 13/21] bridge: add new hwmode swdev
Date: Fri, 28 Nov 2014 14:34:24 +0100
Message-ID: <1417181672-11531-14-git-send-email-jiri@resnulli.us>
References: <1417181672-11531-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.co
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:43197 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615AbaK1Net (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 08:34:49 -0500
Received: by mail-wi0-f181.google.com with SMTP id r20so11280466wiv.2
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2014 05:34:48 -0800 (PST)
In-Reply-To: <1417181672-11531-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Current hwmode settings are "vepa" or "veb".  These are for NIC interfaces
with basic bridging function offloaded to HW.  Add new "swdev" for full
switch device offloads.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
v4->v5:
-fixed indent
v3->v4:
-no change
new in v3
---
 include/uapi/linux/if_bridge.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index da17e45..296a556 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -105,6 +105,7 @@ struct __fdb_entry {
 
 #define BRIDGE_MODE_VEB		0	/* Default loopback mode */
 #define BRIDGE_MODE_VEPA	1	/* 802.1Qbg defined VEPA mode */
+#define BRIDGE_MODE_SWDEV	2	/* Full switch device offload */
 
 /* Bridge management nested attributes
  * [IFLA_AF_SPEC] = {
-- 
1.9.3
