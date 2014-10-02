From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v2 0/2] enic: add support to send port-profile's client name to firmware
Date: Fri,  3 Oct 2014 04:11:21 +0530
Message-ID: <1412289683-8278-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:64340 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752090AbaJBWpZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 18:45:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Firmware has support for sending client name of the port profile to the switch
it's connected to.

This series adds client name to port profile which is sent to hardware while
associating a port profile to VF.

Since port profile are defined in switch, this patch makes it easier to check
what VM is using a port profile.

v2:
Split single patch to multiple patches. First patch adds client name to netlink
facility. Second patch adds driver support.

Govindarajulu Varadarajan (2):
  if_link: add client name to port profile
  enic: add vmname port-profile handler

 drivers/net/ethernet/cisco/enic/enic.h      | 2 ++
 drivers/net/ethernet/cisco/enic/enic_main.c | 6 ++++++
 drivers/net/ethernet/cisco/enic/enic_pp.c   | 5 +++++
 include/uapi/linux/if_link.h                | 1 +
 net/core/rtnetlink.c                        | 2 ++
 5 files changed, 16 insertions(+)

-- 
2.1.0
