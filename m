From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 net-next 0/2] iplink: bridge: add vlan filtering support and show more attributes
Date: Tue, 11 Aug 2015 15:56:22 +0300
Message-ID: <1439297784-1962-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:33218 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755368AbbHKM4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 08:56:36 -0400
Received: by wijp15 with SMTP id p15so175162881wij.0
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 05:56:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Hi,
Patch 01 adds support to show some additional attributes and patch 02
adds support for the recently added IFLA_BR_VLAN_FILTERING attribute.

Cheers,
 Nik

Nikolay Aleksandrov (2):
  iplink: bridge: add ageing_time, stp_state and priority when showing
    attributes
  iplink: bridge: add support for IFLA_BR_VLAN_FILTERING attribute

 include/linux/if_link.h |  1 +
 ip/iplink_bridge.c      | 26 ++++++++++++++++++++++++++
 2 files changed, 27 insertions(+)

-- 
2.4.3
