From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH 0/3] ipvlan: fix ipv6 autoconfiguration via RA
Date: Thu, 14 May 2015 16:56:16 +0300
Message-ID: <20150514134657.14062.87579.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>, Jiri Benc <jbenc@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1g.mail.yandex.net ([95.108.253.251]:44666 "EHLO
	forward-corp1g.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933073AbbENN4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 09:56:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes ipvlan and its interaction with ipv6 RA. Now ipvlan l2
ports get dev_id and construct unique ipv6 addresses using one mac address.

---

Konstantin Khlebnikov (3):
      ipv6: make inet6addr_chain blocking and always call with rtnl locked
      ipvlan: grab rcu_read_lock on xmit path
      ipvlan: set dev_id for l2 ports to generate unique IPv6 addresses


 Documentation/networking/ipvlan.txt |   12 +++++++++++-
 drivers/net/ipvlan/ipvlan.h         |    1 +
 drivers/net/ipvlan/ipvlan_main.c    |   24 ++++++++++++++++++++++++
 net/ipv6/addrconf.c                 |    7 ++++---
 net/ipv6/addrconf_core.c            |    8 ++++----
 5 files changed, 44 insertions(+), 8 deletions(-)

--
Konstantin
