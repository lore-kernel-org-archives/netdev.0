From: Christophe Ricard <christophe.ricard@gmail.com>
Subject: [RFC v3] netlink_ack: send a capped message in case of error
Date: Thu, 27 Aug 2015 21:31:30 +0200
Message-ID: <1440703891-9332-1-git-send-email-christophe-h.ricard@st.com>
Cc: netdev@vger.kernel.org, christophe-h.ricard@st.com,
	christophe.ricard@gmail.com
To: pablo@netfilter.org, jbenc@redhat.com, sfeldma@gmail.com,
	sameo@linux.intel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:33328 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492AbbH0Tbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 15:31:37 -0400
Received: by wicge2 with SMTP id ge2so2739250wic.0
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 12:31:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

After Jiri Benc feedback on my seconds proposal, please find a reworked patch still based on
Pablo Neira Ayuso proposal.

On this patch, I found the sender's socket was saved in netlink_unicast_kernel in NETLINK_CB(skb).sk.
This information now prevent me to look up the socket for every ack.

Also i believe it could be good to make it reach stable as it is somehow a bug fix.

Do you have any other comment ?

Best Regards
Christophe

Christophe Ricard (1):
  netlink: add NETLINK_CAP_ACK socket option

 include/uapi/linux/netlink.h |  1 +
 net/netlink/af_netlink.c     | 27 ++++++++++++++++++++++++---
 2 files changed, 25 insertions(+), 3 deletions(-)

-- 
2.1.4
