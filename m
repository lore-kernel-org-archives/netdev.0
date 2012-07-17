From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] mlx4_en: map entire pages to increase throughput
Date: Tue, 17 Jul 2012 11:17:46 -0700
Message-ID: <5005AC4A.9030208@hp.com>
References: <1342458113-10384-1-git-send-email-cascardo@linux.vnet.ibm.com> <50044F1D.6000703@hp.com> <20120716.222903.367603216293954363.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "cascardo@linux.vnet.ibm.com" <cascardo@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"yevgenyp@mellanox.co.il" <yevgenyp@mellanox.co.il>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"brking@linux.vnet.ibm.com" <brking@linux.vnet.ibm.com>,
	"leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>,
	"klebers@linux.vnet.ibm.com" <klebers@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:23912 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756322Ab2GQSRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 14:17:50 -0400
In-Reply-To: <20120716.222903.367603216293954363.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/16/2012 10:29 PM, David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Mon, 16 Jul 2012 10:27:57 -0700
>
>> That seems rather extraordinarily low - Power7 is supposed to be a
>> rather high performance CPU.  The last time I noticed O(3Gbit/s) on
>> 10G for bulk transfer was before the advent of LRO/GRO - that was in
>> the x86 space though.  Is mapping really that expensive with Power7?
>
> Unfortunately, IOMMU mappings are incredibly expensive.  I see effects
> like this on Sparc too.

OK, so that has caused some dimm memory to get a small refresh - it ends 
up being akin to if not actually a PIO yes?  I recall schemes in drivers 
in other stacks whereby "small" packets were copied because it was 
cheaper to allocate/copy then it was to remap.

rick jones
