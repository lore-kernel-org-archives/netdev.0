From: David Miller <davem@davemloft.net>
Subject: Re: [NET_NEXT RFC PATCH 2/3] ixgbe: added netdev_ops file to
 debugfs
Date: Thu, 10 May 2012 16:32:07 -0400 (EDT)
Message-ID: <20120510.163207.1812696843582837101.davem@davemloft.net>
References: <20120509230945.31910.48302.stgit@localhost6.localdomain6>
	<20120509161320.37fcb705@nehalam.linuxnetplumber.net>
	<F1C1314B3E1AB7499F9BF2A5F0F033EC14A8F3@FMSMSX104.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: catherine.sullivan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54076 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459Ab2EJUcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 16:32:11 -0400
In-Reply-To: <F1C1314B3E1AB7499F9BF2A5F0F033EC14A8F3@FMSMSX104.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Sullivan, Catherine" <catherine.sullivan@intel.com>
Date: Thu, 10 May 2012 20:28:28 +0000

> Could you point me to where this is available in sysfs please? I'm
> not familiar with it.

Is the 'find' program not properly functioning on your computer?

[davem@drr net-next]$ find /sys -type f -name tx_timeout
/sys/devices/virtual/net/lo/queues/tx-0/tx_timeout
/sys/devices/virtual/net/redhat0/queues/tx-0/tx_timeout
/sys/devices/pci0000:00/0000:00:1c.2/0000:06:00.0/net/p34p1/queues/tx-0/tx_timeout
[davem@drr net-next]$ 
