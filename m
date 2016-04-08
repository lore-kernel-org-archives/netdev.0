From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6, token: allow for clearing the current
 device token
Date: Fri, 8 Apr 2016 15:57:53 +0200
Message-ID: <5707B8E1.1060204@stressinduktion.org>
References: <307b4d32099f606d0fbe0ce9fecd3a039b796361.1460123261.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: robbat2@gentoo.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:38363 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752071AbcDHN55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 09:57:57 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 64EB920C4E
	for <netdev@vger.kernel.org>; Fri,  8 Apr 2016 09:57:55 -0400 (EDT)
In-Reply-To: <307b4d32099f606d0fbe0ce9fecd3a039b796361.1460123261.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.04.2016 15:55, Daniel Borkmann wrote:
> The original tokenized iid support implemented via f53adae4eae5 ("net: ipv6:
> add tokenized interface identifier support") didn't allow for clearing a
> device token as it was intended that this addressing mode was the only one
> active for globally scoped IPv6 addresses. Later we relaxed that restriction
> via 617fe29d45bd ("net: ipv6: only invalidate previously tokenized addresses"),
> and we should also allow for clearing tokens as there's no good reason why
> it shouldn't be allowed.
>
> Fixes: 617fe29d45bd ("net: ipv6: only invalidate previously tokenized addresses")
> Reported-by: Robin H. Johnson <robbat2@gentoo.org>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
