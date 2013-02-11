From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: don't accept multicast traffic with scop 0
Date: Mon, 11 Feb 2013 14:52:52 -0500 (EST)
Message-ID: <20130211.145252.603354702530166412.davem@davemloft.net>
References: <20130210124851.GB18219@order.stressinduktion.org>
	<20130211194835.GD23991@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	erik.hugne@ericsson.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759779Ab3BKTw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 14:52:57 -0500
In-Reply-To: <20130211194835.GD23991@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 11 Feb 2013 20:48:35 +0100

> On Sun, Feb 10, 2013 at 01:48:51PM +0100, Hannes Frederic Sowa wrote:
>> +	/*
>> +	 * RFC4291 2.7
>> +	 * Nodes must not originate a packet to a multicast address whose scop
>> +	 * field contains the reserved value 0; if such a packet is received, it
>> +	 * must be silently dropped.
> 
> Just nit-picking: The field is actually called scop without e, as pointed out
> by three erratas to RFC4291. :)

That's funny because I added the 'e' to your patches while applying
them, it just looks completely stupid to refer to this things as
'scop'.
