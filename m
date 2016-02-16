From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 0/5] bridge: complete port netlink support
Date: Tue, 16 Feb 2016 16:08:50 +0100
Message-ID: <1455635335-9973-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35359 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932233AbcBPPJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 10:09:30 -0500
Received: by mail-wm0-f52.google.com with SMTP id c200so166362620wme.0
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 07:09:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Hi,
This small set completes the port netlink support for iproute2 and allows
to view and set all the available netlink port attributes.

Cheers,
 Nik

Nikolay Aleksandrov (5):
  iplink: bridge_slave: export read-only values
  iplink: bridge_slave: add support for IFLA_BRPORT_PROXYARP
  iplink: bridge_slave: add support for IFLA_BRPORT_PROXYARP_WIFI
  iplink: bridge_slave: add support for IFLA_BRPORT_MULTICAST_ROUTER
  iplink: bridge_slave: add support for IFLA_BRPORT_FAST_LEAVE

 ip/ip_common.h           |   2 +
 ip/iplink_bridge.c       |   3 +-
 ip/iplink_bridge_slave.c | 109 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 112 insertions(+), 2 deletions(-)

-- 
2.4.3
