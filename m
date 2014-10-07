From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/2] net: fix a sparse warning
Date: Tue, 07 Oct 2014 00:11:06 -0400 (EDT)
Message-ID: <20141007.001106.65704270134298771.davem@davemloft.net>
References: <1412626971-30271-1-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: azhou@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40857 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbaJGELI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 00:11:08 -0400
In-Reply-To: <1412626971-30271-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>
Date: Mon,  6 Oct 2014 13:22:50 -0700

> Fix a sparse warning introduced by Commit
> 0b5e8b8eeae40bae6ad7c7e91c97c3c0d0e57882 (net: Add Geneve tunneling
> protocol driver) caught by kbuild test robot:
> 
>   # apt-get install sparse
>   #   git checkout 0b5e8b8eeae40bae6ad7c7e91c97c3c0d0e57882
>   #     make ARCH=x86_64 allmodconfig
>   #       make C=1 CF=-D__CHECK_ENDIAN__
>   #
>   #
>   #       sparse warnings: (new ones prefixed by >>)
>   #
>   #       >> net/ipv4/geneve.c:230:42: sparse: incorrect type in assignment (different base types)
>   #          net/ipv4/geneve.c:230:42:    expected restricted __be32 [addressable] [assigned] [usertype] s_addr
>   #             net/ipv4/geneve.c:230:42:    got unsigned long [unsigned] <noident>
>   #
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Andy Zhou <azhou@nicira.com>

Applied.
