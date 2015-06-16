From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 net-next 0/3] iplink_bridge: add support for ageing_time, priority and stp_state
Date: Tue, 16 Jun 2015 13:38:46 +0300
Message-ID: <1434451129-3241-1-git-send-email-razor@blackwall.org>
Cc: stephen@networkplumber.org, joerg@higgsboson.tk,
	davem@davemloft.net, Nikolay Aleksandrov <razor@blackwall.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36974 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756186AbbFPKxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 06:53:16 -0400
Received: by wifx6 with SMTP id x6so15428283wif.0
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 03:53:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Three months ago support was added to be able to set ageing_time,
priority and stp_state via netlink by commit:
af615762e972 ("bridge: add ageing_time, stp_state, priority over netlink")
This patch-set adds support for iproute2 to be able to use them.
Exampes:
ip link set dev br0 type bridge priority 10
ip link set dev br0 type bridge ageing_time 10
ip link set dev br0 type bridge stp_state 1


Best regards,
 Nikolay Aleksandrov

Nikolay Aleksandrov (3):
  iplink_bridge: add support for ageing_time
  iplink_bridge: add support for stp_state
  iplink_bridge: add support for priority

 ip/iplink_bridge.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

-- 
2.4.3
