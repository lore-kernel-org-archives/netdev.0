From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sky2: fix hang in napi_disable
Date: Thu, 17 Nov 2011 21:15:42 -0500 (EST)
Message-ID: <20111117.211542.2100089519209667535.davem@davemloft.net>
References: <20111117.205234.394141688162787655.davem@davemloft.net>
	<f582e628-7770-43c5-aa90-51cf74141462@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: svenjoac@gmx.de, netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41489 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752751Ab1KRCPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 21:15:46 -0500
In-Reply-To: <f582e628-7770-43c5-aa90-51cf74141462@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Thu, 17 Nov 2011 18:10:49 -0800 (PST)

> 
>> From: Stephen Hemminger <shemminger@vyatta.com>
>> Date: Thu, 17 Nov 2011 16:37:35 -0800
>> 
>> > If IRQ was never initialized, then calling napi_disable() would
>> > hang.
>> > Add more bookkeeping to track whether IRQ was ever initialized.
>> > 
>> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>> 
>> Stephen, your other 6 patches went into 'net' so you have to target
>> these fixes there too.
>> 
> 
> Do you need me to respin them?

If they apply cleanly to 'net', no.  Do they?
