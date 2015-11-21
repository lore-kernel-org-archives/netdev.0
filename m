From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 0/9] net: ipmr: cleanups and minor improvements
Date: Sat, 21 Nov 2015 14:01:33 +0100
Message-ID: <1448110902-28793-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34217 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697AbbKUNBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 08:01:48 -0500
Received: by wmvv187 with SMTP id v187so105477637wmv.1
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2015 05:01:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Hi,
Since I'll have to work with ipmr, I decided to clean it up and do some
minor improvements. Functionally there're almost no changes except the
SLAB_PANIC removal. Most of the patches just re-design some functions to
be clearer and more concise and try to remove the ifdef web that was
inside. There's more information in each commit. This is the first set,
the end goal is to introduce complete netlink support and control over
the mfc and vif devices.
I've tried to test all of the setsockopt/getsockopt options, and also
made builds with various ipmr kconfig options turned on and off.

Thank you,
 Nik

Nikolay Aleksandrov (9):
  net: ipmr: move the tbl id check in ipmr_new_table
  net: ipmr: always define mroute_reg_vif_num
  net: ipmr: remove some pimsm ifdefs and simplify
  net: ipmr: fix code and comment style
  net: ipmr: make ip_mroute_getsockopt more understandable
  net: ipmr: drop an instance of CONFIG_IP_MROUTE_MULTIPLE_TABLES
  net: ipmr: remove SLAB_PANIC
  net: ipmr: rearrange and cleanup setsockopt
  net: ipmr: factor out common vif init code

 include/uapi/linux/mroute.h |  59 ++---
 net/ipv4/ipmr.c             | 597 ++++++++++++++++++++------------------------
 2 files changed, 285 insertions(+), 371 deletions(-)

-- 
2.4.3
