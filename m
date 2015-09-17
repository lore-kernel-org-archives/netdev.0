From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RFC] net: increase LL_MAX_HEADER for Hyper-V
Date: Thu, 17 Sep 2015 13:10:37 -0700 (PDT)
Message-ID: <20150917.131037.2286760949122849895.davem@davemloft.net>
References: <BY2PR0301MB16547020327B59C72692E730A05A0@BY2PR0301MB1654.namprd03.prod.outlook.com>
	<20150917.115218.655587837796826886.davem@davemloft.net>
	<BY2PR0301MB1654790C65E4E7EC98A76946A05A0@BY2PR0301MB1654.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, alexander.duyck@gmail.com,
	haiyangz@microsoft.com, vkuznets@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jasowang@redhat.com
To: kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45337 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbbIQUKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 16:10:40 -0400
In-Reply-To: <BY2PR0301MB1654790C65E4E7EC98A76946A05A0@BY2PR0301MB1654.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: KY Srinivasan <kys@microsoft.com>
Date: Thu, 17 Sep 2015 19:52:01 +0000

> 
> 
>> -----Original Message-----
>> Have a pre-cooked ring of buffers for these descriptors that you can
>> point the chip at.  No per-packet allocation is necessary at all.
> 
> Even if I had a ring of buffers, I would still need to manage the life cycle
> of these buffers - selecting an unused one on the transmit path and marking
> it used (atomically).

Have one per TX ring entry, then the lifetime matches the lifetime of the
TX entry itself and therefore you need do nothing.

That's the whole idea.
