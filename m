From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] net/mlx4: Add support to SRIOV VF
 management ndo calls
Date: Thu, 25 Apr 2013 04:33:11 -0400 (EDT)
Message-ID: <20130425.043311.783987350023639431.davem@davemloft.net>
References: <1366821674-17902-1-git-send-email-ogerlitz@mellanox.com>
	<20130424.163049.2212021825718596200.davem@davemloft.net>
	<5178E535.10804@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ronye@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754098Ab3DYIdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 04:33:13 -0400
In-Reply-To: <5178E535.10804@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 25 Apr 2013 11:11:33 +0300

> On 24/04/2013 23:30, David Miller wrote:
>> From: Or Gerlitz <ogerlitz@mellanox.com>
>> Date: Wed, 24 Apr 2013 19:41:08 +0300
>>
>>> This series adds support for the SRIOV ndo_set_vf callbacks to the
>>> mlx4 driver.
>>>
>>> Series done against the net-next tree as of commit 0c501345c
>>> "batman-adv: fix
>>> global protection fault during soft_iface destruction".
>>>
>>> We have successfully tested the series on net-next, except for getting
>>> the VF link info issue I have reported earlier today on netdev, we
>>> see the problem for both ixgbe and mlx4 VFs. Just to make sure get
>>> VF config is working OK with patch #6 - we have run it over 3.8.8 too.
>> Series applied, thanks.
> 
> Hi Dave, Looking on your patchwork archive, I see indeed that the
> series was accepted, e.g
> 
> patch 1/6 http://patchwork.ozlabs.org/patch/239279/
> patch 2/6 http://patchwork.ozlabs.org/patch/239274/
> patch 3/6 http://patchwork.ozlabs.org/patch/239277/
> patch 4/6 http://patchwork.ozlabs.org/patch/239276/
> patch 5/6 http://patchwork.ozlabs.org/patch/239278/
> patch 6/6 http://patchwork.ozlabs.org/patch/239275/
> 
> but for some reason the patches don't appear on your kernel.org
> net-next tree, anything went wrong here?

Actually, the series didn't apply, I have no idea why I said that I
applied it.

It conflicts with other changes already in net-next, namely the
NETIF_F_* vlan hw capability flag renaming done by Patrick McHardy.

Also, in patch #4:

/home/davem/src/GIT/net-next/.git/rebase-apply/patch:125: new blank line at EOF.

do not add files that end in an empty line.

Please fix this all up and resubmit, thanks.
