From: Chema Gonzalez <chema@google.com>
Subject: [PATCH net-next] tcp_cubic: fix typo in module param description
Date: Tue, 18 Apr 2017 19:22:23 -0700
Message-ID: <20170419022223.28318-1-chema@google.com>
Cc: netdev@vger.kernel.org, Chema Gonzalez <chemag@gmail.com>
To: David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34762 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932779AbdDSCWa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 22:22:30 -0400
Received: by mail-pf0-f179.google.com with SMTP id c198so5113486pfc.1
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 19:22:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chema Gonzalez <chemag@gmail.com>

Signed-off-by: Chema Gonzalez <chemag@gmail.com>
---
 net/ipv4/tcp_cubic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index c99230efcd52..0683ba447d77 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -72,7 +72,7 @@ MODULE_PARM_DESC(tcp_friendliness, "turn on/off tcp friendliness");
 module_param(hystart, int, 0644);
 MODULE_PARM_DESC(hystart, "turn on/off hybrid slow start algorithm");
 module_param(hystart_detect, int, 0644);
-MODULE_PARM_DESC(hystart_detect, "hyrbrid slow start detection mechanisms"
+MODULE_PARM_DESC(hystart_detect, "hybrid slow start detection mechanisms"
 		 " 1: packet-train 2: delay 3: both packet-train and delay");
 module_param(hystart_low_window, int, 0644);
 MODULE_PARM_DESC(hystart_low_window, "lower bound cwnd for hybrid slow start");
-- 
2.12.2.816.g2cccc81164-goog
