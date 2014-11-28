From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 02/21] neigh: sort Neighbor Cache Entry Flags
Date: Fri, 28 Nov 2014 14:34:13 +0100
Message-ID: <1417181672-11531-3-git-send-email-jiri@resnulli.us>
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
Received: from mail-wi0-f173.google.com ([209.85.212.173]:42806 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559AbaK1Neh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 08:34:37 -0500
Received: by mail-wi0-f173.google.com with SMTP id r20so18582352wiv.6
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2014 05:34:35 -0800 (PST)
In-Reply-To: <1417181672-11531-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suggested-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
v4->v5:
-no change
new in v4
---
 include/uapi/linux/neighbour.h | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
index 4a1d7e9..2f043af 100644
--- a/include/uapi/linux/neighbour.h
+++ b/include/uapi/linux/neighbour.h
@@ -35,11 +35,10 @@ enum {
  */
 
 #define NTF_USE		0x01
-#define NTF_PROXY	0x08	/* == ATF_PUBL */
-#define NTF_ROUTER	0x80
-
 #define NTF_SELF	0x02
 #define NTF_MASTER	0x04
+#define NTF_PROXY	0x08	/* == ATF_PUBL */
+#define NTF_ROUTER	0x80
 
 /*
  *	Neighbor Cache Entry States.
-- 
1.9.3
