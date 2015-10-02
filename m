From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 0/4] bridge: vlan: cleanups & fixes (part 2)
Date: Fri,  2 Oct 2015 15:05:09 +0200
Message-ID: <1443791113-12738-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, vyasevich@gmail.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:38652 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbbJBNHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 09:07:06 -0400
Received: by wiclk2 with SMTP id lk2so30285217wic.1
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 06:07:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Hi,
This is the second follow-up set with one fix (patch 01) and more cleanups
(patches 02,03 and 04). These are minor compared to the previous ones and
should be the last before taking on the optimization changes on the
fast-path.

Cheers,
 Nik

Nikolay Aleksandrov (4):
  bridge: vlan: use rcu list for the ordered vlan list
  bridge: vlan: use br_vlan_(get|put)_master to deal with refcounts
  bridge: vlan: drop master_flags from __vlan_add
  bridge: vlan: use br_vlan_should_use to simplify __vlan_add/del

 net/bridge/br_netlink.c |  10 ++++-
 net/bridge/br_private.h |   2 +-
 net/bridge/br_vlan.c    | 102 +++++++++++++++++++++++++++---------------------
 3 files changed, 66 insertions(+), 48 deletions(-)

-- 
2.4.3
