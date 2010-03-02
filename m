From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: fix tx completion polling
Date: Tue, 02 Mar 2010 03:56:49 -0800 (PST)
Message-ID: <20100302.035649.53340739.davem@davemloft.net>
References: <20100225115516.GA10784@serverengines.com>
	<20100226.041926.36027143.davem@davemloft.net>
	<20100302063615.GA6480@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52115
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752295Ab0CBL4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 06:56:31 -0500
In-Reply-To: <20100302063615.GA6480@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Tue, 2 Mar 2010 12:06:15 +0530

> On 26/02/10 04:19 -0800, David Miller wrote:
>> From: Sathya Perla <sathyap@serverengines.com>
>> Date: Thu, 25 Feb 2010 17:25:16 +0530
>> 
>> > In tx/mcc polling, napi_complete() is being incorrectly called
>> > before reaping tx completions. This can cause tx compl processing
>> > to be scheduled on another cpu concurrently which can result in a panic.
>> > This if fixed by calling napi complete() after tx/mcc compl processing
>> > but before re-enabling interrupts (via a cq notify).
>> > 
>> > Pls apply to net-2.6.
>> 
>> net-2.6 is closed, 2.6.33 has been released.
>> 
>> > Signed-off-by: Sathya Perla <sathyap@serverengines.com>
>> 
>> This patch does not apply to net-next-2.6
> 
> I've re-done the patch for net-next-2.6: Pls apply; thanks!
> 
> In tx/mcc polling, napi_complete() is being incorrectly called
> before reaping tx completions. This can cause tx compl processing
> to be scheduled on another cpu concurrently which can result in a panic.
> This if fixed by calling napi complete() after tx/mcc compl processing
> but before re-enabling interrupts (via a cq notify).
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied thanks.
