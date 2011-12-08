From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/2] be2net: workaround to fix a BE bug
Date: Thu, 08 Dec 2011 00:09:47 -0500 (EST)
Message-ID: <20111208.000947.193581253177810925.davem@davemloft.net>
References: <20111207234424.GA2385@akhaparde-VBox>
	<20111208.000044.1859009201427703594.davem@davemloft.net>
	<1323320840.1762.61.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ajit.khaparde@Emulex.Com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52443 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715Ab1LHFJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 00:09:55 -0500
In-Reply-To: <1323320840.1762.61.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 07 Dec 2011 21:07:20 -0800

> On Thu, 2011-12-08 at 00:00 -0500, David Miller wrote:
>> From: Ajit Khaparde <ajit.khaparde@Emulex.Com>
>> > +	if (unlikely(vlan_tx_tag_present(skb) &&
>> > +		(skb->ip_summed != CHECKSUM_PARTIAL || skb->len <= 60))) {
>> Poorly formatted, the second line opening first non-space character
>> needs to line up precisely after the first column after the if() statements
>> opening parenthesis.
> 
> In this case I believe you mean after the unlikely(
> 
> 	if (unlikely(vlan_tx_tag_present(skb) &&
> 		     (skb->ip_summed != CHECKSUM_PARTIAL || skb->len <= 60))) {

Right.
