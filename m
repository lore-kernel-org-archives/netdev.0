From: "Sullivan, Catherine" <catherine.sullivan@intel.com>
Subject: RE: [NET_NEXT RFC PATCH 2/3] ixgbe: added netdev_ops file to debugfs
Date: Thu, 10 May 2012 21:14:49 +0000
Message-ID: <F1C1314B3E1AB7499F9BF2A5F0F033EC14AA1B@FMSMSX104.amr.corp.intel.com>
References: <20120509230945.31910.48302.stgit@localhost6.localdomain6>
	<20120509161320.37fcb705@nehalam.linuxnetplumber.net>
	<F1C1314B3E1AB7499F9BF2A5F0F033EC14A8F3@FMSMSX104.amr.corp.intel.com>
 <20120510.163207.1812696843582837101.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:35230 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757447Ab2EJVPI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 17:15:08 -0400
In-Reply-To: <20120510.163207.1812696843582837101.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was aware of this, however this does not allow a call to the ndo_tx_timeout function which is what my patch does. Is there a way to do this with sysfs? I could not find this functionality. 

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Thursday, May 10, 2012 1:32 PM

From: "Sullivan, Catherine" <catherine.sullivan@intel.com>
Date: Thu, 10 May 2012 20:28:28 +0000

> Could you point me to where this is available in sysfs please? I'm not 
> familiar with it.

Is the 'find' program not properly functioning on your computer?

[davem@drr net-next]$ find /sys -type f -name tx_timeout /sys/devices/virtual/net/lo/queues/tx-0/tx_timeout
/sys/devices/virtual/net/redhat0/queues/tx-0/tx_timeout
/sys/devices/pci0000:00/0000:00:1c.2/0000:06:00.0/net/p34p1/queues/tx-0/tx_timeout
[davem@drr net-next]$ 
