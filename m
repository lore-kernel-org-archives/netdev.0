From: Christophe Ricard <christophe.ricard@gmail.com>
Subject: [PATCH v4] netlink_ack: send a capped message in case of error
Date: Fri, 28 Aug 2015 07:07:47 +0200
Message-ID: <1440738468-2374-1-git-send-email-christophe-h.ricard@st.com>
Cc: netdev@vger.kernel.org, christophe-h.ricard@st.com,
	christophe.ricard@gmail.com
To: pablo@netfilter.org, jbenc@redhat.com, sfeldma@gmail.com,
	sameo@linux.intel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38773 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbbH1FHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 01:07:54 -0400
Received: by wicgk12 with SMTP id gk12so10103565wic.1
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 22:07:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

After Jiri Benc feedback on my seconds proposal, please find a reworked patch still based on
Pablo Neira Ayuso proposal. Compared to v3 i have removed Cc: stable@vger.kernel.org.

Could you queue it up for -stable ?

On this patch, I found the sender's socket was saved in netlink_unicast_kernel in NETLINK_CB(skb).sk.
This information now prevent me to look up the socket for every ack.

Best Regards
Christophe

Christophe Ricard (1):
  netlink: add NETLINK_CAP_ACK socket option

 include/uapi/linux/netlink.h |  1 +
 net/netlink/af_netlink.c     | 27 ++++++++++++++++++++++++---
 2 files changed, 25 insertions(+), 3 deletions(-)

-- 
2.1.4
