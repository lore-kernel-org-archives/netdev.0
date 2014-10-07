From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 2/2] openvswitch: fix a sparse warning
Date: Tue, 07 Oct 2014 00:11:13 -0400 (EDT)
Message-ID: <20141007.001113.76143573614116152.davem@davemloft.net>
References: <1412626971-30271-1-git-send-email-azhou@nicira.com>
	<1412626971-30271-2-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: azhou@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40860 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528AbaJGELP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 00:11:15 -0400
In-Reply-To: <1412626971-30271-2-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>
Date: Mon,  6 Oct 2014 13:22:51 -0700

> Fix a sparse warning introduced by commit:
> f5796684069e0c71c65bce6a6d4766114aec1396 (openvswitch: Add support for
> Geneve tunneling.) caught by kbuild test robot:
> 
> reproduce:
>   # apt-get install sparse
>   #   git checkout f5796684069e0c71c65bce6a6d4766114aec1396
>   #     make ARCH=x86_64 allmodconfig
>   #       make C=1 CF=-D__CHECK_ENDIAN__
>   #
>   #
>   #       sparse warnings: (new ones prefixed by >>)
>   #
>   #       >> net/openvswitch/vport-geneve.c:109:15: sparse: incorrect type in assignment (different base types)
>   #          net/openvswitch/vport-geneve.c:109:15:    expected restricted __be16 [usertype] sport
>   #             net/openvswitch/vport-geneve.c:109:15:    got int
>   #             >> net/openvswitch/vport-geneve.c:110:56: sparse: incorrect type in argument 3 (different base types)
>   #                net/openvswitch/vport-geneve.c:110:56:    expected unsigned short [unsigned] [usertype] value
>   #                   net/openvswitch/vport-geneve.c:110:56:    got restricted __be16 [usertype] sport
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Andy Zhou <azhou@nicira.com>

Applied.
