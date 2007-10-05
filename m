From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 19:32:31 -0400
Message-ID: <4706C98F.1060601@garzik.org>
References: <20071005.031209.57156822.davem@davemloft.net>	<20071005083556.7076dd43@freepuppy.rosehill> <20071005.162400.35026372.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	Ariel.Hendel@sun.com, greg.onufer@sun.com,
	Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59368 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758853AbXJEXce (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 19:32:34 -0400
In-Reply-To: <20071005.162400.35026372.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Fri, 5 Oct 2007 08:35:56 -0700
> 
>>> +static void niu_log_rxchan_errors(struct niu *np, struct rx_ring_info *rp,
>>> +				  u64 stat)
>>> +{
>>> +	printk(KERN_ERR PFX "%s: RX channel %u errors ( ",
>>> +	       np->dev->name, rp->rx_channel);
>> dev_err??
> 
> I've made conversions over to dev_err() where possible.
> 
> Thanks!
> 
>>From cbc4b58382eab08aa231f23d21839c011b4c9f8c Mon Sep 17 00:00:00 2001
> From: David S. Miller <davem@sunset.davemloft.net>
> Date: Fri, 5 Oct 2007 16:22:39 -0700
> Subject: [PATCH] [NIU]: Use dev_err().
> 
> Suggested by Stephen Hemminger.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

It seems you made redundant 1/2 of the comment I just sent :)

ACK


