From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 0/2] bridge: vlan: failure path and comment fixes
Date: Fri, 30 Oct 2015 17:46:18 +0100
Message-ID: <1446223580-1464-1-git-send-email-razor@blackwall.org>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	nikolay@cumulusnetworks.com, idosch@mellanox.com,
	roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38198 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770AbbJ3QyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 12:54:17 -0400
Received: by wmeg8 with SMTP id g8so16458819wme.1
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 09:54:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Hi,
This is a set from Ido which takes care of one failure path error in
nbp_vlan_init (patch 1) and a few comment errors (patch 2).
I must admit I didn't expect the port init continues after a vlan init
failure but should've checked to make sure. Thanks to Ido for catching
these!

Cheers,
 Nik

Ido Schimmel (2):
  bridge: vlan: Prevent possible use-after-free
  bridge: vlan: Use correct flag name in comment

 net/bridge/br_vlan.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

-- 
2.4.3
