From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH -next 0/3] net: cap size to original frag size when
 refragmenting
Date: Mon, 13 Apr 2015 20:56:35 +0200
Message-ID: <1428951395.3836898.253202125.37FEDCB5@webmail.messagingengine.com>
References: <1428704189-31247-1-git-send-email-fw@strlen.de>
 <20150413.135348.461869719021663434.davem@davemloft.net>
 <1428950452.3833058.253180861.49ADF43A@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:41226 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932565AbbDMS4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 14:56:36 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 9FADE2106D
	for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 14:56:35 -0400 (EDT)
In-Reply-To: <1428950452.3833058.253180861.49ADF43A@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 13, 2015, at 20:40, Hannes Frederic Sowa wrote:
> In the end netfilter has to deal with fragments where the split is in
> the transport layer (like a split directly in the tcp header to confuse
> firewalls, fragment offset=1). To do this correctly, I think we have to
> always pass in the original skb.

Sorry, by 'original' I meant the fully reassembled skb.

Bye,
Hannes
