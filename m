From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH net-next 0/2] New ARPHRD type for 6LoWPAN
Date: Sat,  7 Dec 2013 20:08:55 +0200
Message-ID: <1386439737-14894-1-git-send-email-jukka.rissanen@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55153 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754761Ab3LGSJD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Dec 2013 13:09:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

new ARPHRD needed for 6LoWPAN networks. Initially this will
be used by Bluetooth sub-system but IEEE 802154 will be converted
to use it also. The patch using this new ARPHRD is sent to
bluetooth mailing list.

Cheers,
Jukka

Jukka Rissanen (2):
  net: if_arp: add ARPHRD_6LOWPAN type
  ipv6: Add checks for 6LOWPAN ARP type

 include/uapi/linux/if_arp.h | 1 +
 net/ipv6/addrconf.c         | 4 +++-
 2 files changed, 4 insertions(+), 1 deletion(-)

-- 
1.8.3.1
