From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Fix br_should_learn to check vlan_enabled
Date: Tue, 16 Sep 2014 12:05:43 -0400 (EDT)
Message-ID: <20140916.120543.1664186205219105157.davem@davemloft.net>
References: <1410809066-4434-1-git-send-email-vyasevic@redhat.com>
	<20140915.173849.609066505150727105.davem@davemloft.net>
	<541813AB.2060301@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, netdev@vger.kernel.org,
	toshiaki.makita1@gmail.com, vyasevic@redhat.com
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540AbaIPQFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 12:05:47 -0400
In-Reply-To: <541813AB.2060301@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Tue, 16 Sep 2014 19:40:43 +0900

> On 2014/09/16 6:38, David Miller wrote:
>> From: Vladislav Yasevich <vyasevich@gmail.com>
>> Date: Mon, 15 Sep 2014 15:24:26 -0400
>> 
>>> As Toshiaki Makita pointed out, the BRIDGE_INPUT_SKB_CB will
>>> not be initialized in br_should_learn() as that function
>>> is called only from br_handle_local_finish().  That is
>>> an input handler for link-local ethernet traffic so it perfectly
>>> correct to check br->vlan_enabled here.
>>>
>>> Reported-by: Toshiaki Makita<toshiaki.makita1@gmail.com>
>>> Fixes: 20adfa1 bridge: Check if vlan filtering is enabled only once.
>>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>> 
>> Applied, thanks Vlad.
> 
> Hi David,
> 
> Could you queue this for -stable as well?

Done.
