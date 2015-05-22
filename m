From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH -next 1/2] net: ipv4: avoid repeated calls to
 ip_skb_dst_mtu helper
Date: Fri, 22 May 2015 16:43:37 +0200
Message-ID: <1432305817.28081.2.camel@stressinduktion.org>
References: <1432305171-21932-1-git-send-email-fw@strlen.de>
	 <1432305171-21932-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:59058 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756767AbbEVOnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 10:43:40 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 980DF2051F
	for <netdev@vger.kernel.org>; Fri, 22 May 2015 10:43:39 -0400 (EDT)
In-Reply-To: <1432305171-21932-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2015-05-22 at 16:32 +0200, Florian Westphal wrote:
> ip_skb_dst_mtu is small inline helper, but its called in several places.
> 
> before: 17061      44       0   17105    42d1 net/ipv4/ip_output.o
> after:  16805      44       0   16849    41d1 net/ipv4/ip_output.o
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

This also does reduce some dst_mtu === dst->ops->mtu() indirect calls,
maybe also giving a tiny speed-up. :)

Bye,
Hannes
