From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next 0/4] geneve: Use LWT more effectively.
Date: Thu, 17 Nov 2016 23:10:25 -0800
Message-ID: <1479453029-29619-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:40710 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751471AbcKRHKf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 02:10:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch series make use of geneve LWT code path for
geneve netdev type of device.
This allows us to simplify geneve module.

Pravin B Shelar (4):
  geneve: Unify LWT and netdev handling.
  geneve: Merge ipv4 and ipv6 geneve_build_skb()
  geneve: Remove redundant socket checks.
  geneve: Optimize geneve device lookup.

 drivers/net/geneve.c | 678 +++++++++++++++++++++------------------------------
 1 file changed, 273 insertions(+), 405 deletions(-)

-- 
1.8.3.1
