From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 00/10] vmxnet3: patches
Date: Tue, 15 Jan 2013 09:28:25 -0800
Message-ID: <1358270915-32758-1-git-send-email-stephen@networkplumber.org>
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:55717 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756248Ab3AORaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 12:30:03 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so232775pad.5
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 09:30:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor VMXNET3 cleanup found while reviewing driver.

Stephen Hemminger (10):
  vmxnet3: use netdev_alloc_skb_ip_align
  vmxnet3: remove unnecessary bookkeeping
  vmxnet3: fix messages printed before registration
  vmxnet3: use netdev_dbg
  vmxnet3: use netdev_ printk wrappers
  vmxnet3: remove VMXNET3_MAX_DEVICES
  vmxnet3: remove device counter
  vmxnet3: remove unused irq_share_mode
  vmxnet3: use static RSS key
  vmxnet3: better RSS support

 drivers/net/vmxnet3/vmxnet3_drv.c     |  227 ++++++++++++++++-----------------
 drivers/net/vmxnet3/vmxnet3_ethtool.c |   13 +-
 drivers/net/vmxnet3/vmxnet3_int.h     |    3 -
 3 files changed, 118 insertions(+), 125 deletions(-)

-- 
1.7.10.4
