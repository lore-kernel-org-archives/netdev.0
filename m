From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH v2 0/1] tc reclassification needs to consider ether protocol changes
Date: Wed, 17 Feb 2016 06:37:34 -0500
Message-ID: <1455709055-30881-1-git-send-email-jhs@emojatatu.com>
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:33859 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161304AbcBQLhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 06:37:47 -0500
Received: by mail-io0-f177.google.com with SMTP id 9so32327957iom.1
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 03:37:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

v2:
Use Daniel's suggestion on when to set the skb proto
v1:
fix compile error found by build bot when CONFIG_NET_CLS_ACT was off


Jamal Hadi Salim (1):
  net_sched fix: reclassification needs to consider ether protocol
    changes

 net/sched/sch_api.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

-- 
1.9.1
