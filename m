From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net v2 0/1] reflect mark on tcp syn ack packets
Date: Mon,  3 Jul 2017 09:51:49 -0400
Message-ID: <1499089910-20034-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, lorenzo@google.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34429 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934024AbdGCNwC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 09:52:02 -0400
Received: by mail-io0-f194.google.com with SMTP id r70so2914386ioe.1
        for <netdev@vger.kernel.org>; Mon, 03 Jul 2017 06:52:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>


Changes from v1(Lorenzo):
unconditionally set skb->mark = ireq->ir_mark;

Jamal Hadi Salim (1):
  net: reflect mark on tcp syn ack packets

 net/ipv4/ip_output.c  | 3 ++-
 net/ipv4/tcp_output.c | 1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

-- 
1.9.1
