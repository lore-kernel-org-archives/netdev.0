From: "Anton 'EvilMan' Danilov" <littlesmilingcloud@gmail.com>
Subject: [PATCH iproute] csum action, fix typo
Date: Wed, 29 Feb 2012 19:48:27 +0300
Message-ID: <CAEzD07+RtbLgfvtbB3f_PUcEkEnK6B9ks1O+R2uUK5afOyxqSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58779 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755932Ab2B2Qs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 11:48:28 -0500
Received: by wgbdr13 with SMTP id dr13so3929346wgb.1
        for <netdev@vger.kernel.org>; Wed, 29 Feb 2012 08:48:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix typo in csum action output.

diff --git a/tc/m_csum.c b/tc/m_csum.c
index d251335..f7da6f0 100644
--- a/tc/m_csum.c
+++ b/tc/m_csum.c
@@ -215,7 +215,7 @@ print_csum(struct action_util *au, FILE * f,
struct rtattr *arg)
		} while(0)
	CSUM_UFLAG_BUFFER(uflag_2, TCA_CSUM_UPDATE_FLAG_ICMP, "icmp");
	CSUM_UFLAG_BUFFER(uflag_3, TCA_CSUM_UPDATE_FLAG_IGMP, "igmp");
-	CSUM_UFLAG_BUFFER(uflag_4, TCA_CSUM_UPDATE_FLAG_TCP, "tdp");
+	CSUM_UFLAG_BUFFER(uflag_4, TCA_CSUM_UPDATE_FLAG_TCP, "tcp");
	CSUM_UFLAG_BUFFER(uflag_5, TCA_CSUM_UPDATE_FLAG_UDP, "udp");
	CSUM_UFLAG_BUFFER(uflag_6, TCA_CSUM_UPDATE_FLAG_UDPLITE, "udplite");
	if (!uflag_count) {

-- 
Anton.
