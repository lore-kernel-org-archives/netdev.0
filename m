From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 0/2] flow_dissector: dissect tunnel info
Date: Mon,  2 Oct 2017 10:41:14 +0200
Message-ID: <1506933676-20121-1-git-send-email-simon.horman@netronome.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:53119 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750891AbdJBIlf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 04:41:35 -0400
Received: by mail-wr0-f176.google.com with SMTP id k62so3314251wrc.9
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 01:41:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move dissection of tunnel info from the flower classifier to the flow
dissector where all other dissection occurs.  This should not have any
behavioural affect on other users of the flow dissector.

Simon Horman (2):
  net/dst: Make skb parameter of skb{metadata_dst,tunnel_info}() const
  flow_dissector: dissect tunnel info

 include/net/dst_metadata.h |   5 ++-
 net/core/flow_dissector.c  | 100 +++++++++++++++++++++++++++++++++++++++++++++
 net/sched/cls_flower.c     |  25 ------------
 3 files changed, 103 insertions(+), 27 deletions(-)

-- 
2.1.4
