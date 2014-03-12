From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] mlx4 fixes
Date: Wed, 12 Mar 2014 16:14:08 -0400 (EDT)
Message-ID: <20140312.161408.2149985285610209.davem@davemloft.net>
References: <1394637392-31104-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41248 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963AbaCLUOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 16:14:10 -0400
In-Reply-To: <1394637392-31104-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 12 Mar 2014 17:16:29 +0200

> These short series fixes two bugs related to the vxlan support and a
> missing req module call for the IB driver which is needed to support
> IB/RDMA over Ethernet.
> 
> Pathes done over the net tree, commit dd38743 "vlan: Set correct
> source MAC address with TX VLAN offload enabled"

Series applied, thanks Or.

I wonder though, if a MAC address change results in a VLAN steering
rule insertion failure, won't we be left in an inconsistent state?
