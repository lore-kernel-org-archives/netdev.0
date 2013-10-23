From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netpoll: fix rx_hook() interface by passing the skb
Date: Wed, 23 Oct 2013 16:16:03 -0400 (EDT)
Message-ID: <20131023.161603.1190144528425577653.davem@davemloft.net>
References: <20131023102848.GB1535@neomailbox.net>
	<AE90C24D6B3A694183C094C60CF0A2F6026B73A4@saturn3.aculab.com>
	<20131023124401.GC1535@neomailbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753045Ab3JWUQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 16:16:04 -0400
In-Reply-To: <20131023124401.GC1535@neomailbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Wed, 23 Oct 2013 14:44:01 +0200

> On Wed, Oct 23, 2013 at 12:18:32PM +0100, David Laight wrote:
>> > My idea is to use the following API:
>> > 
>> > rx_skb_hook(struct netpoll *np, int source, struct sk_buff *skb, int len);
>> > 
>> > Any suggestion or objection?
>> 
>> Don't you need to pass the offset of the udp data?
> 
> Yes, you are right. I just forgot it. Therefore we have:
> 
> rx_skb_hook(struct netpoll *np, int source, struct sk_buff *skb, int offset,
> 	    int len);
> 
> where offset is going to be = (udp_hdr + 1) - skb->data
> and len = skb->len - offset

This looks good to me.
