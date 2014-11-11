From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net-next 0/2] mlx4: Add CHECKSUM_COMPLETE support
Date: Tue, 11 Nov 2014 13:23:44 -0500 (EST)
Message-ID: <20141111.132344.1257075560135801416.davem@davemloft.net>
References: <1415533913-7012-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matanb@mellanox.com, amirv@mellanox.com,
	saeedm@mellanox.com, shanim@mellanox.com, idos@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59970 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087AbaKKSXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 13:23:48 -0500
In-Reply-To: <1415533913-7012-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  9 Nov 2014 13:51:51 +0200

> These patches from Shani, Matan and myself add support for 
> CHECKSUM_COMPLETE reporting on non TCP/UDP packets such as 
> GRE and ICMP. I'd like to deeply thank Jerry Chu for his 
> innovation and support in that effort.
> 
> Based on the feedback from Eric and Ido Shamay, in V2 we dropped 
> the patch which removed the calls to napi_gro_frags() and added 
> a patch which makes the RX code to go through that path 
> regardless of the checksum status.

Series applied, thanks Or.
