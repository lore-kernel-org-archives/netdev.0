From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next v3 0/4] geneve: Use LWT more effectively.
Date: Mon, 21 Nov 2016 11:02:57 -0800
Message-ID: <1479754981-17600-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:57036 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754303AbcKUTDI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 14:03:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch series make use of geneve LWT code path for
geneve netdev type of device.
This allows us to simplify geneve module without changing any
functionality.

v2-v3:
Rebase against latest net-next.

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
