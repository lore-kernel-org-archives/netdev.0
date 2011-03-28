From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] myri10ge: small rx_done refactoring
Date: Sun, 27 Mar 2011 18:35:14 -0700 (PDT)
Message-ID: <20110327.183514.35025158.davem@davemloft.net>
References: <20110325112123.GA6218@redhat.com>
	<4D8C92B9.1010109@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, netdev@vger.kernel.org, brice@myri.com,
	shemminger@vyatta.com, dhowells@redhat.com,
	bhutchings@solarflare.com
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51282
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753215Ab1C1Bfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 21:35:52 -0400
In-Reply-To: <4D8C92B9.1010109@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Fri, 25 Mar 2011 09:03:53 -0400

> On 03/25/11 07:21, Stanislaw Gruszka wrote:
>> Avoid theoretical race condition regarding accessing dev->features
>> NETIF_F_LRO flag, which is illustrated below.
>>
 ...
>>
>> On the way reduce myri10ge_rx_done() number of arguments and calls by
>> moving mgp->small_bytes check into that function. That reduce code
>> size
>>
...
>>
>> on my i686 system, what should also make myri10ge_clean_rx_done()
>> being faster.
>>
>> Signed-off-by: Stanislaw Gruszka<sgruszka@redhat.com>
> 
> Thank you very much!
> 
> Acked by: Andrew Gallatin <gallatin@myri.com>

Applied, thanks everyone.
