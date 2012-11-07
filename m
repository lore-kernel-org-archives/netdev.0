From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 5/6] net: calxedaxgmac: rework transmit ring handling
Date: Tue, 06 Nov 2012 20:10:52 -0500 (EST)
Message-ID: <20121106.201052.1632236238198110122.davem@davemloft.net>
References: <1352132544-15809-6-git-send-email-robherring2@gmail.com>
	<20121106.185704.1212469675670236955.davem@davemloft.net>
	<5099AB57.7000805@calxeda.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: rob.herring@calxeda.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753693Ab2KGBK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 20:10:56 -0500
In-Reply-To: <5099AB57.7000805@calxeda.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>
Date: Tue, 06 Nov 2012 18:29:11 -0600

> David,
> 
> On 11/06/2012 05:57 PM, David Miller wrote:
>> From: Rob Herring <robherring2@gmail.com>
>> Date: Mon,  5 Nov 2012 10:22:23 -0600
>> 
>>> Only generate tx interrupts on every ring size / 4 descriptors.
>> 
>> I thought we told you that you cannot do this.
>> 
>> With this change if we get a few packets, then stop generating any
>> traffic, there will be SKBs that just sit dead in your TX queue.
> 
> And as I previously mentioned, we do get a tx complete interrupt in
> addition. The h/w will interrupt when all packets are transmitted and
> there is not another descriptor ready.

Ok, in that case it's fine.  I'll keep reviewing this series then.
