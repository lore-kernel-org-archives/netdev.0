From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v7] Add support of Cavium Liquidio ethernet
 adapters
Date: Mon, 27 Apr 2015 12:27:31 -0400 (EDT)
Message-ID: <20150427.122731.2291810668949579803.davem@davemloft.net>
References: <1429922056-14124-1-git-send-email-rvatsavayi@caviumnetworks.com>
	<20150426.160407.2043024228389437605.davem@davemloft.net>
	<BY1PR0701MB1706BF510E830F151F5E1BC5FEE90@BY1PR0701MB1706.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Raghu.Vatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
	Satananda.Burla@caviumnetworks.com,
	Felix.Manlunas@caviumnetworks.com
To: Derek.Chickles@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55627 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753037AbbD0Q1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 12:27:34 -0400
In-Reply-To: <BY1PR0701MB1706BF510E830F151F5E1BC5FEE90@BY1PR0701MB1706.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Chickles, Derek" <Derek.Chickles@caviumnetworks.com>
Date: Mon, 27 Apr 2015 16:26:27 +0000

>> 
>> It is extremely disappointing that you've defined your own debug
>> logging macros, which use generic dev_*() printks, instead of using
>> the proper netdev_*() printk logging interfaces to do this.
> 
> We can make this change. I'm not sure why it was missed since we
> have netif_level support. Please note, we will still need to use the
> dev_ macros for those places in the driver where we don't have a
> netdev yet.

Of course.

But there is no reason to go through a special locally defined
macros to do this stuff.  Just invoke dev_* and netdev_* directly.
