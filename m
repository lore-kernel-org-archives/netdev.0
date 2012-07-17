From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_en: map entire pages to increase throughput
Date: Tue, 17 Jul 2012 13:20:19 -0700 (PDT)
Message-ID: <20120717.132019.1633094178309164749.davem@davemloft.net>
References: <20120716.222903.367603216293954363.davem@davemloft.net>
	<5005AC4A.9030208@hp.com>
	<5005C6A0.50002@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, cascardo@linux.vnet.ibm.com,
	netdev@vger.kernel.org, yevgenyp@mellanox.co.il,
	ogerlitz@mellanox.com, amirv@mellanox.com,
	leitao@linux.vnet.ibm.com, klebers@linux.vnet.ibm.com
To: brking@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54452 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755206Ab2GQUUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 16:20:22 -0400
In-Reply-To: <5005C6A0.50002@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian King <brking@linux.vnet.ibm.com>
Date: Tue, 17 Jul 2012 15:10:08 -0500

> On 07/17/2012 01:17 PM, Rick Jones wrote:
>> On 07/16/2012 10:29 PM, David Miller wrote:
>>> From: Rick Jones <rick.jones2@hp.com> Date: Mon, 16 Jul 2012
>>> 10:27:57 -0700
>>> 
>>>> That seems rather extraordinarily low - Power7 is supposed to be
>>>> a rather high performance CPU.  The last time I noticed
>>>> O(3Gbit/s) on 10G for bulk transfer was before the advent of
>>>> LRO/GRO - that was in the x86 space though.  Is mapping really
>>>> that expensive with Power7?
>>> 
>>> Unfortunately, IOMMU mappings are incredibly expensive.  I see
>>> effects like this on Sparc too.
>> 
>> OK, so that has caused some dimm memory to get a small refresh - it
>> ends up being akin to if not actually a PIO yes?  I recall schemes in
>> drivers in other stacks whereby "small" packets were copied because
>> it was cheaper to allocate/copy then it was to remap.
> 
> On Power it ends up being an hcall to the hypervisor

This is true on sparc64 niagara systems as well.
