From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 0/2] vxlan, geneve: fix hlist corruption
Date: Sun,  2 Jul 2017 19:00:56 +0200
Message-ID: <cover.1499014738.git.jbenc@redhat.com>
Cc: Waiman Long <longman@redhat.com>,
        "John W. Linville" <linville@tuxdriver.com>,
        pravin shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43718 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751682AbdGBRBQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 2 Jul 2017 13:01:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix memory corruption introduced with the support of both IPv4 and IPv6
sockets in a single device. The same bug is present in VXLAN and Geneve.

Signed-off-by: Jiri Benc <jbenc@redhat.com>


Jiri Benc (2):
  vxlan: fix hlist corruption
  geneve: fix hlist corruption

 drivers/net/geneve.c | 48 ++++++++++++++++++++++++++++++++----------------
 drivers/net/vxlan.c  | 30 ++++++++++++++++++++----------
 include/net/vxlan.h  | 10 +++++++++-
 3 files changed, 61 insertions(+), 27 deletions(-)

-- 
1.8.3.1
