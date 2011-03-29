From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb3: Apply interrupt coalescing settings to all
 queues
Date: Mon, 28 Mar 2011 22:27:17 -0700 (PDT)
Message-ID: <20110328.222717.59681471.davem@davemloft.net>
References: <20110328135041.57cec646@kryten>
	<4D90C862.2080207@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@vger.kernel.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59494
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751665Ab1C2F1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 01:27:55 -0400
In-Reply-To: <4D90C862.2080207@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Mon, 28 Mar 2011 10:41:54 -0700

> On 03/27/2011 07:50 PM, Anton Blanchard wrote:
>>
>>
>> While testing the performance of different receive interrupt
>> coalescing settings on a single stream TCP benchmark, I noticed two
>> very different results. With rx-usecs=50, most of the time a
>> connection would hit 8280 Mbps but once in a while it would hit
>> 9330 Mbps.
>>
>> It turns out we are only applying the interrupt coalescing settings
>> to the first queue and whenever the rx hash would direct us onto
>> that queue we ran faster.
>>
>> With this patch applied and rx-usecs=50, I get 9330 Mbps
>> consistently.
>>
>> Signed-off-by: Anton Blanchard <anton@samba.org>
> 
> Acked-by: Divy Le Ray <divy@chelsio.com>

Applied, thanks.
