From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] enic: fix compile when CONFIG_PCI_IOV is
 not enabled
Date: Fri, 20 Jan 2012 13:40:05 -0500 (EST)
Message-ID: <20120120.134005.1489924902535382966.davem@davemloft.net>
References: <20120120082536.18521.86316.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdunlap@xenotime.net
To: roprabhu@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754899Ab2ATSkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 13:40:12 -0500
In-Reply-To: <20120120082536.18521.86316.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>
Date: Fri, 20 Jan 2012 00:25:36 -0800

> From: Roopa Prabhu <roprabhu@cisco.com>
> 
> reverting back change that access enic->num_vfs outside
> CONFIG_PCI_IOV
> 
> Reported-by: Randy Dunlap <rdunlap@xenotime.net>
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>

Applied, thanks.

I don't see how you can be asking this to be applied to the net-next
tree.  I applied your patches to the plain 'net' tree and therefore
this patch won't apply to net-next at all, go and see for yourself
if you don't believe me. :-)
