From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH 0/2] Add support for ARPHRD_RAWIP
Date: Wed, 30 Oct 2013 11:11:09 +0200
Message-ID: <1383124271-15290-1-git-send-email-jukka.rissanen@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32073 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751650Ab3J3JLN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 05:11:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This new type is needed in Bluetooth 6LoWPAN where
raw IPv6 packets are transferred to/from the device.

I used the same value (530) as some Android kernels
(from Qualcomm) are using in order not to brake any
user space programs. If this is not needed, I can
certainly send a new patch version with next available
value (519).

Cheers,
Jukka


Jukka Rissanen (2):
  net: if_arp: add ARPHRD_RAWIP type
  ipv6: Add checks for RAWIP ARP type

 include/uapi/linux/if_arp.h |  1 +
 net/ipv6/addrconf.c         | 14 +++++++++++++-
 2 files changed, 14 insertions(+), 1 deletion(-)

-- 
1.7.11.7
