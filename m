From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net PATCH v3 0/1] tc reclassification needs to consider ether protocol changes
Date: Thu, 18 Feb 2016 07:38:03 -0500
Message-ID: <1455799084-6166-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:33351 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422694AbcBRMiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 07:38:13 -0500
Received: by mail-ig0-f170.google.com with SMTP id y8so12538725igp.0
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 04:38:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

v3:
Cong says this needs to go to -net. And to put back the removed new line

v2:
Use Daniel's suggestion on when to set the skb proto

v1:
fix compile error found by build bot when CONFIG_NET_CLS_ACT was off

Jamal Hadi Salim (1):
  net_sched fix: reclassification needs to consider ether protocol
    changes

 net/sched/sch_api.c | 1 +
 1 file changed, 1 insertion(+)

-- 
1.9.1
