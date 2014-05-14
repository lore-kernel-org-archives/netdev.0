From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: systemport: Use devm_ioremap_resource()
Date: Wed, 14 May 2014 15:42:27 -0400 (EDT)
Message-ID: <20140514.154227.2067283859735753797.davem@davemloft.net>
References: <001c01cf6f22$c9fe6f60$5dfb4e20$%han@samsung.com>
	<CAGVrzcb5M-jZgZJnLKA8gzdnEV52aKtmuj1O9r5EbbOp=xuBmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jg1.han@samsung.com, netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53772 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418AbaENTm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 15:42:29 -0400
In-Reply-To: <CAGVrzcb5M-jZgZJnLKA8gzdnEV52aKtmuj1O9r5EbbOp=xuBmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 13 May 2014 21:05:21 -0700

> 2014-05-13 20:15 GMT-07:00 Jingoo Han <jg1.han@samsung.com>:
>> Use devm_ioremap_resource() because devm_request_and_ioremap() is
>> obsoleted by devm_ioremap_resource().
> 
> As of net-next of today, I see nothing that warns when using this
> function that it is obsolete, nor is it commented as such, how about
> it gets annotated with __deprecated so people stop using it even for
> new submissions?
> 
>>
>> Signed-off-by: Jingoo Han <jg1.han@samsung.com>
> 
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Applied to net-next, thanks.
