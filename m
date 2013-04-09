From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 07/11] tg3: Add support for link flap avoidance
Date: Tue, 09 Apr 2013 17:07:27 -0400 (EDT)
Message-ID: <20130409.170727.1353692158695327368.davem@davemloft.net>
References: <1365533291-5672-8-git-send-email-nsujir@broadcom.com>
	<20130409.151540.1097356797775302170.davem@davemloft.net>
	<5164811C.2030005@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: nsujir@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39841 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936446Ab3DIVHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 17:07:31 -0400
In-Reply-To: <5164811C.2030005@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Tue, 9 Apr 2013 13:59:08 -0700

> On 04/09/2013 12:15 PM, David Miller wrote:
>> From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
>> Date: Tue, 9 Apr 2013 11:48:07 -0700
>>
>> If we force a PHY reset due to EEE changes, will the ASF traffic
>> disruption warning message be emitted?
> 
> No, the message is not emitted. There are a couple of reasons for
> this.
> 
> 1. The intent of the message is to warn on user initiated operations
> that cause a link flap.
> 
> 2. The link flap due to EEE mismatch and force reset is possible the
> very first time the system is powered on. It's reasonable to expect
> the link to be in flux till the driver is in sync.
> 
> After the 1st time the EEE mismatch can only happen if the user
> modfies it via ethtool. tg3 does not yet support the set_eee ethtool
> handler. When we implement that, we will add the warning there similar
> to the other ethtool op handlers.

Ok, thanks for the explanation.
