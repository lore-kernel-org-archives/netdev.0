From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC net-next] sfc: add support for skb->xmit_more
Date: Wed, 15 Oct 2014 12:20:34 -0400 (EDT)
Message-ID: <20141015.122034.126232757997381022.davem@davemloft.net>
References: <alpine.LFD.2.03.1410141933500.26972@solarflare.com>
	<20141014.171501.448630399243434370.davem@davemloft.net>
	<543E54FF.1040304@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, nikolay@redhat.com, netdev@vger.kernel.org,
	sshah@solarflare.com, jcooper@solarflare.com,
	linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52145 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429AbaJOQUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 12:20:37 -0400
In-Reply-To: <543E54FF.1040304@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Wed, 15 Oct 2014 12:05:35 +0100

> On 14/10/14 22:15, David Miller wrote:
>> From: Edward Cree <ecree@solarflare.com>
>> Date: Tue, 14 Oct 2014 19:41:37 +0100
>>
>>> Don't ring the doorbell, and don't do PIO.  This will also prevent
>>>  TX Push, because there will be more than one buffer waiting when
>>>  the doorbell is rung.
>>>
>>> Signed-off-by: Edward Cree <ecree@solarflare.com>
>> This looks good to me, mind if I apply this now?
> I'd rather wait until Jon Cooper's had a chance to look at it; he
> understands our TX path better than I.

Ok.
