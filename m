From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Why does e1000 (in net-2.6) have extra pseudo-netdevices
Date: Fri, 25 Jul 2008 12:04:15 -0700
Message-ID: <20080725120415.396e479a@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeffery.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peterj.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:51089 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753368AbYGYTES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 15:04:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we have multi-queue tx, and multi-napi, why does E1000 still
have extra fake network devices?


 static int __devinit e1000_alloc_queues(struct e1000_adapter *adapter)
{
...
       adapter->polling_netdev = kcalloc(adapter->num_rx_queues,
                                          sizeof(struct net_device),
                                          GFP_KERNEL);
