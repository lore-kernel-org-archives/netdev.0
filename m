From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 0/2] net: propagate max_gso_segs and max_gso_size
Date: Mon, 21 Mar 2016 09:55:09 -0700
Message-ID: <1458579311-17699-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Petri Gynther <pgynther@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35429 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756915AbcCUQzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 12:55:15 -0400
Received: by mail-pf0-f178.google.com with SMTP id n5so270924370pfn.2
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2016 09:55:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge code does not properly update max_gso_segs and max_gso_size.

Since this was not really obvious, first patch adds two new rtnetlink
attributes to help debugging this kind of issues (ip -d link)

Second patch fixes bridge code.

Eric Dumazet (2):
  net/rtnetlink: add IFLA_GSO_MAX_SEGS and IFLA_GSO_MAX_SIZE attributes
  bridge: update max_gso_segs and max_gso_size

 include/uapi/linux/if_link.h |  2 ++
 net/bridge/br_if.c           | 16 ++++++++++++++++
 net/core/rtnetlink.c         |  4 ++++
 3 files changed, 22 insertions(+)

-- 
2.8.0.rc3.226.g39d4020
