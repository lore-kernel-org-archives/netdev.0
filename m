From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 net 1/8] tc/pedit: Fix a typo in pedit usage message
Date: Sun, 23 Apr 2017 15:53:49 +0300
Message-ID: <20170423125356.1298-2-amir@vadai.me>
References: <20170423125356.1298-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35825 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1045427AbdDWMyh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 08:54:37 -0400
Received: by mail-wm0-f66.google.com with SMTP id d79so12528770wmi.2
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 05:54:37 -0700 (PDT)
In-Reply-To: <20170423125356.1298-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 tc/m_pedit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 8e9bf0720dfe..939a6a1455a5 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -40,7 +40,7 @@ static void explain(void)
 		"\t<RAW>:= <OFFSETC>[ATC]<CMD>\n \t\tOFFSETC:= offset <offval> <u8|u16|u32>\n"
 		"\t\tATC:= at <atval> offmask <maskval> shift <shiftval>\n"
 		"\t\tNOTE: offval is byte offset, must be multiple of 4\n"
-		"\t\tNOTE: maskval is a 32 bit hex number\n \t\tNOTE: shiftval is a is a shift value\n"
+		"\t\tNOTE: maskval is a 32 bit hex number\n \t\tNOTE: shiftval is a shift value\n"
 		"\t\tCMD:= clear | invert | set <setval>| retain\n"
 		"\t<LAYERED>:= ip <ipdata> | ip6 <ip6data>\n"
 		" \t\t| udp <udpdata> | tcp <tcpdata> | icmp <icmpdata>\n"
-- 
2.12.0
