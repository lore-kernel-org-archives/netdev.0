From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6.25 2/4]S2io: Multiqueue network device support - FIFO
 selection based on L4 ports
Date: Thu, 21 Feb 2008 00:21:48 +0100
Message-ID: <47BCB60C.3040409@trash.net>
References: <47BCB304.9050709@trash.net>	<20080220.151244.79005114.davem@davemloft.net>	<47BCB481.8050203@trash.net> <20080220.151834.133850272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ramkrishna.Vepa@neterion.com, Sreenivasa.Honnur@neterion.com,
	netdev@vger.kernel.org, jeff@garzik.org, support@neterion.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62915 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763895AbYBTXWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 18:22:01 -0500
In-Reply-To: <20080220.151834.133850272.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 21 Feb 2008 00:15:13 +0100
>
>   
>> I missed those discussions, but this has already been agreed on,
>> fine by me. It would still be preferable to use queue_mapping
>> instead of priority IMO, even if its activated by a module
>> parameter, since that leaves the option to use classifiers.
>>     
>
> I think the driver should compute the value in it's transmit
> routine and keep the value local.  It shouldn't be setting
> skb->foo values at all, they don't belong to the driver
> and this could confuse other code.
>   

Yes, I didn't meant it should set anything, but on of the options
this patch introduces is to _use_ skb->priority for classification,
so the classification is already external, in which case it might
as well offer the full flexibility (as one option) to use qdisc
classifiers.



