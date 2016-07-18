From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, allow segmentation for local udp tunneled skbs
Date: Mon, 18 Jul 2016 12:48:59 +0200
Message-ID: <abb3f2be-e2bb-5683-d152-ff30fc53a306@stressinduktion.org>
References: <1468582987-18990-1-git-send-email-shmulik.ladkani@gmail.com>
 <27e9a6c3-1648-892c-bcaa-254e5332a42e@stressinduktion.org>
 <20160718131111.6d4c0540@pixies>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	shmulik.ladkani@ravellosystems.com,
	Eric Dumazet <edumazet@google.com>,
	Florian Westphal <fw@strlen.de>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:57215 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750994AbcGRKtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 06:49:03 -0400
In-Reply-To: <20160718131111.6d4c0540@pixies>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18.07.2016 12:11, Shmulik Ladkani wrote:
> On Mon, 18 Jul 2016 12:06:00 +0200, hannes@stressinduktion.org wrote:
>>> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
>>
>> I think this is reasonable, thanks!
>>
>> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> Thanks for the feedback and assistance.
> 
> I'll spin a v3 with a tiny coding change.

Ah, then you can make allow_frag bool, please.

Thanks,
Hannes
