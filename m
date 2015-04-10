From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH -next 1/3] ipv4: reject too-big defragmented DF-skb when
 forwarding
Date: Sat, 11 Apr 2015 00:51:20 +0200
Message-ID: <1428706280.2052307.251919509.22467B5C@webmail.messagingengine.com>
References: <1428704189-31247-1-git-send-email-fw@strlen.de>
 <1428704189-31247-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:35432 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751560AbbDJWvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 18:51:21 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id A6254209C7
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:51:16 -0400 (EDT)
In-Reply-To: <1428704189-31247-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 11, 2015, at 00:16, Florian Westphal wrote:
> Send icmp pmtu error if we find that the largest fragment of df-skb
> exceeded the output path mtu.
> 
> The ip output path will still catch this later on but we can avoid the
> forward/postrouting hook traversal by rejecting right away.
> 
> This is what ipv6 already does.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Also,
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

I think this is the right thing to do not create pmtu blackholes

Bye,
Hannes
