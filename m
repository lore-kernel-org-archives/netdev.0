From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 03/21] bridge: convert flags in fbd entry into bitfields
Date: Thu, 27 Nov 2014 11:40:08 +0100
Message-ID: <1417084826-9875-4-git-send-email-jiri@resnulli.us>
References: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
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
Received: from mail-wi0-f174.google.com ([209.85.212.174]:61315 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754184AbaK0Kkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 05:40:33 -0500
Received: by mail-wi0-f174.google.com with SMTP id h11so15348530wiw.1
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 02:40:32 -0800 (PST)
In-Reply-To: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suggested-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
new in v4
---
 net/bridge/br_private.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 8f3f081..5b37077 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -98,9 +98,9 @@ struct net_bridge_fdb_entry
 	unsigned long			updated;
 	unsigned long			used;
 	mac_addr			addr;
-	unsigned char			is_local;
-	unsigned char			is_static;
-	unsigned char			added_by_user;
+	unsigned char			is_local:1,
+					is_static:1,
+					added_by_user:1;
 	__u16				vlan_id;
 };
 
-- 
1.9.3
