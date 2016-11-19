From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next v2 0/4] geneve: Use LWT more effectively.
Date: Fri, 18 Nov 2016 18:10:07 -0800
Message-ID: <1479521411-53012-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:50770 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752315AbcKSCKT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 21:10:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch series make use of geneve LWT code path for
geneve netdev type of device.
This allows us to simplify geneve module.

v1-v2:
Fix warning reported by kbuild test robot.

Pravin B Shelar (4):
  geneve: Unify LWT and netdev handling.
  geneve: Merge ipv4 and ipv6 geneve_build_skb()
  geneve: Remove redundant socket checks.
  geneve: Optimize geneve device lookup.

 drivers/net/geneve.c | 679 +++++++++++++++++++++------------------------------
 1 file changed, 274 insertions(+), 405 deletions(-)

-- 
1.8.3.1
