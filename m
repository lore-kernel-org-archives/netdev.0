From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/2] net: DSA fixes for bridge and ip-autoconf
Date: Fri, 16 Jan 2015 09:56:00 -0800
Message-ID: <1421430962-18119-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, stephen@networkplumber.org, kaber@trash.net,
	bridge@lists.linux-foundation.org, buytenh@wantstofly.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:64077 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865AbbAPR4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 12:56:16 -0500
Received: by mail-pd0-f170.google.com with SMTP id p10so12492797pdj.1
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 09:56:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

These two patches address some real world use cases of the DSA master and slave
network devices.

You have already seen patch 1 previously and you rejected it since my
explanations were not good enough to provide a justification as to why it is
useful, hopefully this time my explanation is better.

Patch 2 solves a different, yet very real problem as well at the bridge layer
when using DSA network devices.

Florian Fainelli (2):
  net: ipv4: handle DSA enabled master network devices
  net: bridge: reject DSA-enabled master netdevices as bridge members

 net/bridge/br_if.c  | 10 ++++++++--
 net/ipv4/ipconfig.c |  6 +++---
 2 files changed, 11 insertions(+), 5 deletions(-)

-- 
2.1.0
