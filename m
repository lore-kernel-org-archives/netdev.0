From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 5/7] tcp_nv: make tcpnv_get_info static
Date: Tue, 10 Jan 2017 10:18:14 -0800
Message-ID: <20170110181816.18991-6-sthemmin@microsoft.com>
References: <20170110181816.18991-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34958 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939989AbdAJSSa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 13:18:30 -0500
Received: by mail-pf0-f177.google.com with SMTP id f144so41277899pfa.2
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 10:18:30 -0800 (PST)
In-Reply-To: <20170110181816.18991-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function only used in this file.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/ipv4/tcp_nv.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_nv.c b/net/ipv4/tcp_nv.c
index 5de82a8d4d87..0065f44c40c1 100644
--- a/net/ipv4/tcp_nv.c
+++ b/net/ipv4/tcp_nv.c
@@ -424,8 +424,8 @@ static void tcpnv_acked(struct sock *sk, const struct ack_sample *sample)
 }
 
 /* Extract info for Tcp socket info provided via netlink */
-size_t tcpnv_get_info(struct sock *sk, u32 ext, int *attr,
-		      union tcp_cc_info *info)
+static size_t tcpnv_get_info(struct sock *sk, u32 ext, int *attr,
+			     union tcp_cc_info *info)
 {
 	const struct tcpnv *ca = inet_csk_ca(sk);
 
-- 
2.11.0
