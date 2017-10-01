From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 0/4] ip_gre: a bunch of fixes for erspan
Date: Sun,  1 Oct 2017 22:00:52 +0800
Message-ID: <cover.1506866059.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Dmitry Kozlov <xeb@mail.ru>,
        William Tu <u9012063@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36176 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750981AbdJAOBF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 10:01:05 -0400
Received: by mail-pg0-f68.google.com with SMTP id d8so3311181pgt.3
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 07:01:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is to fix some issues that could cause 0 or low
performance, and even unexpected truncated packets on erspan.

Xin Long (4):
  ip_gre: get key from session_id correctly in erspan_rcv
  ip_gre: check packet length and mtu correctly in erspan_xmit
  ip_gre: set tunnel hlen properly in erspan_tunnel_init
  ip_gre: erspan device should keep dst

 net/ipv4/ip_gre.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

-- 
2.1.0
