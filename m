From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 2/6] bridge/fdb: fix statistics output spacing
Date: Thu,  4 Dec 2014 09:57:14 +0100
Message-ID: <1417683438-10935-3-git-send-email-jiri@resnulli.us>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
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
Received: from mail-wg0-f43.google.com ([74.125.82.43]:61215 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125AbaLDI5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 03:57:24 -0500
Received: by mail-wg0-f43.google.com with SMTP id l18so22266165wgh.2
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 00:57:23 -0800 (PST)
In-Reply-To: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 bridge/fdb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index a55fac1..d678342 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -142,7 +142,7 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		struct nda_cacheinfo *ci = RTA_DATA(tb[NDA_CACHEINFO]);
 		int hz = get_user_hz();
 
-		fprintf(fp, " used %d/%d", ci->ndm_used/hz,
+		fprintf(fp, "used %d/%d ", ci->ndm_used/hz,
 		       ci->ndm_updated/hz);
 	}
 	if (r->ndm_flags & NTF_SELF)
-- 
1.9.3
