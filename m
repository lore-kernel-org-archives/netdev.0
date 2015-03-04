From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] be2net: patch set
Date: Wed, 04 Mar 2015 15:59:05 -0500 (EST)
Message-ID: <20150304.155905.224074842471355703.davem@davemloft.net>
References: <1425447874-5406-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49534 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbbCDU7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 15:59:06 -0500
In-Reply-To: <1425447874-5406-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Wed, 4 Mar 2015 00:44:31 -0500

> Hi Dave, the following patch set includes three feature additions relating
> to SR-IOV to be2net. 
> 
> Patch 1 avoid creating a non-RSS default RXQ when FW allows it.
> This prevents wasting one RXQ for each VF.
> 
> Patch 2 adds support for evenly distributing all queue & filter resources
> across VFs. The FW informs the driver as to which resources are distributable.
> 
> Patch 3 implements the sriov_configure PCI method to allow runtime
> enablement of VFs via sysfs.
> 
> Pls consider applying this patch-set to the net-next tree. Thanks!

Series applied, thanks.
