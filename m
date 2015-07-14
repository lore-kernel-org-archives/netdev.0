From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH v3 0/5] ipvlan: cleanups and fixes
Date: Tue, 14 Jul 2015 16:35:49 +0300
Message-ID: <20150714132941.22448.42175.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Benc <jbenc@redhat.com>
To: linux-netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1o.mail.yandex.net ([37.140.190.172]:45174 "EHLO
	forward-corp1o.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751901AbbGNNfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 09:35:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1: http://comments.gmane.org/gmane.linux.network/363346
v2: http://comments.gmane.org/gmane.linux.network/369086

v3 has reduced set of patches from "ipvlan: fix ipv6 autoconfiguration".
Here just cleanups and patch which ignores ipv6 notifications from RA.

---

Konstantin Khlebnikov (4):
      ipvlan: remove counters of ipv4 and ipv6 addresses
      ipvlan: plug memory leak in ipvlan_link_delete
      ipvlan: unhash addresses without synchronize_rcu
      ipvlan: ignore addresses from ipv6 autoconfiguration

WANG Cong (1):
      ipvlan: use rcu_deference_bh() in ipvlan_queue_xmit()


 drivers/net/ipvlan/ipvlan.h      |    9 +++++---
 drivers/net/ipvlan/ipvlan_core.c |    6 ++---
 drivers/net/ipvlan/ipvlan_main.c |   42 +++++++++++++++++---------------------
 3 files changed, 27 insertions(+), 30 deletions(-)

--
Signature
