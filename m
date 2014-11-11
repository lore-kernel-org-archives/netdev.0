From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: fix IPV6_PKTINFO with v4 mapped
Date: Tue, 11 Nov 2014 11:32:53 +0100
Message-ID: <1415701973.1480480.189577857.01B63915@webmail.messagingengine.com>
References: <1415670865.9613.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:33105 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751623AbaKKKcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 05:32:55 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 398DE200CA
	for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 05:32:54 -0500 (EST)
In-Reply-To: <1415670865.9613.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2014, at 02:54, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Use IS_ENABLED(CONFIG_IPV6), to enable this code if IPv6 is
> a module.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: c8e6ad0829a7 ("ipv6: honor IPV6_PKTINFO with v4 mapped addresses
> on sendmsg")

Oops, thanks for fixing.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
