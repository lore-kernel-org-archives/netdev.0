From: greearb@candelatech.com
Subject: [PATCH 0/2] Allow NICs to pass Frame Checksum up the stack.
Date: Fri, 17 Jun 2011 12:40:13 -0700
Message-ID: <1308339615-5866-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53820 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752561Ab1FQTkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 15:40:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This series provides ethtool support to set and get the rx-checksum
flag, and adds support to the e100 driver.

Assuming this series is acceptable, I would then propose a series of patches
to allow receiving all frames, even ones with bad checksums, etc.

And if that is acceptable, a third series would allow user-space to generate
packets with custom ethernet frame checksums (ie, bad ones if desired).

And finally, more drivers, such as e1000 and hopefully e100e can
be supported.

v2:  Make naming more consistent, use get/set_value.

Ben Greear (2):
  net:  Support getting/setting RX-FCS in drivers.
  e100:  Support receiving Ethernet FCS.

 drivers/net/e100.c      |   35 ++++++++++++++++++++++++++++++++---
 include/linux/ethtool.h |    8 ++++++++
 net/core/ethtool.c      |    8 ++++++++
 3 files changed, 48 insertions(+), 3 deletions(-)

-- 
1.7.3.4

