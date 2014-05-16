From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] mlx4: Fix VF MAC address change under RoCE
 usage
Date: Thu, 15 May 2014 23:39:58 -0400 (EDT)
Message-ID: <20140515.233958.2173839819606514748.davem@davemloft.net>
References: <1400156968-29633-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, matanb@mellanox.com,
	roland@kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39049 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752616AbaEPDkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 23:40:00 -0400
In-Reply-To: <1400156968-29633-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 15 May 2014 15:29:26 +0300

> Hi Dave, Roland

I don't see Roland Dreier on the CC: list, I have added him.

> This short series provides proper handling for the case where a 
> VF netdevice change their MAC address under a RoCE use case. The code
> it deals with was introduced in 3.15-rc1
> 
> Prior to this series the source MAC used for the VM RoCE CM
> packets remains as before the MAC modification. Hence RoCE CM 
> packets sent by the VF will not carry the same source MAC 
> address as the non-CM packets.
> 
> Earlier 3.15-rc commit f24f790 "net/mlx4_core: Load the Eth driver 
> first" handled just one instance of the problem, but this one 
> provides a more generic and proper solution which covers all 
> cases of VF mac change.
> 
> Matan and Or.

Do you guys want this to go via my 'net' tree or via Roland's
'infiniband' tree?
