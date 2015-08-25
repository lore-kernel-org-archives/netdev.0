From: Christophe Ricard <christophe.ricard@gmail.com>
Subject: [RFC v2] netlink_ack: send a capped message in case of error
Date: Tue, 25 Aug 2015 21:43:28 +0200
Message-ID: <1440531809-26963-1-git-send-email-christophe-h.ricard@st.com>
Cc: netdev@vger.kernel.org,
	Christophe Ricard <christophe-h.ricard@st.com>
To: pablo@netfilter.org, jbenc@redhat.com, sfeldma@gmail.com,
	sameo@linux.intel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:35656 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631AbbHYTnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 15:43:35 -0400
Received: by wicne3 with SMTP id ne3so24970671wic.0
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 12:43:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Thanks to my first RFC proposal to cap a netlink message in case of an error, i have
rebased my work on Pablo Neira Ayuso.
After some few trials, it appears to me in_skb->sk is not the correct socket to deal with.

Here comes a reworked and tested version based on Pablo's one.

Also i believe it could be good to make it reach stable as it is somehow a bug fix.

What do you think ?

Best Regards
Christophe

Christophe Ricard (1):
  netlink: add NETLINK_CAP_ACK socket option

 include/uapi/linux/netlink.h |  1 +
 net/netlink/af_netlink.c     | 49 ++++++++++++++++++++++++++++++++------------
 2 files changed, 37 insertions(+), 13 deletions(-)

-- 
2.1.4
