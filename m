From: Scott Talbert <talbert@techie.net>
Subject: Re: [PATCH] cdc_ether/zaurus: Move Harmony 900 from cdc_ether to
 zaurus
Date: Mon, 20 Feb 2012 19:50:57 -0500 (EST)
Message-ID: <alpine.LRH.2.02.1202201943040.31081@bear.techie.net>
References: <alpine.LRH.2.02.1202192018500.16782@bear.techie.net> <20120220.192915.1058416494686295446.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.techie.net ([205.134.185.202]:34620 "EHLO bear.techie.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754914Ab2BUAvA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Feb 2012 19:51:00 -0500
In-Reply-To: <20120220.192915.1058416494686295446.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Feb 2012, David Miller wrote:

> From: Scott Talbert <talbert@techie.net>
> Date: Sun, 19 Feb 2012 20:35:29 -0500 (EST)
>
>> The Logitech Harmony 900 remote control appears to use the pseudo-MDLM
>> driver, rather than the standard one.  This patch simply moves the
>> device so that it gets picked up by the correct driver.
>>
>> Signed-off-by: Scott Talbert <talbert@techie.net>
>
> You're not moving anything, you're adding the ID to not one but two
> different drivers.
>
> That doesn't make any sense to me, so either this patch is completely
> wrong or you need to rewrite your commit message to explain things
> better and more accurately.

Sorry, to clarify...in the current baseline, the Harmony 900 gets picked 
up by the cdc_ether driver by this generic line in cdc_ether.c:

 	USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_MDLM,
 			USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long)&wwan_info,

The intent of my patch is to blacklist the Harmony 900 from cdc_ether and 
whitelist it in zaurus.

Scott
