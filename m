From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Report dev->promiscuity in netlink reports.
Date: Sun, 01 Apr 2012 23:35:00 -0400 (EDT)
Message-ID: <20120401.233500.1228632795205982039.davem@davemloft.net>
References: <1333061490-4484-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47218 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754196Ab2DBDfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:35:03 -0400
In-Reply-To: <1333061490-4484-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: greearb@candelatech.com
Date: Thu, 29 Mar 2012 15:51:30 -0700

> From: Ben Greear <greearb@candelatech.com>
> 
> The standard ways of probing a device's promiscuity
> (ifi_flags, for instance) does not report the actual
> state of the device.  This patch adds dev->promiscuity
> to the netlink netdevice report so that users can know
> for certain if the device is acting PROMISC or not.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

Ok, applied to net-next, thanks.
