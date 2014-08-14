From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] tcp: fix tcp_release_cb() to dispatch via address
 family for mtu_reduced()
Date: Thu, 14 Aug 2014 20:39:33 +0200
Message-ID: <1408041573.25187.2.camel@localhost>
References: <1408034405-30596-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [66.111.4.27] ([66.111.4.27]:60130 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754585AbaHNSkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 14:40:11 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway1.nyi.internal (Postfix) with ESMTP id 219A2242D7
	for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 14:39:46 -0400 (EDT)
In-Reply-To: <1408034405-30596-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Do, 2014-08-14 at 12:40 -0400, Neal Cardwell wrote:
> Make sure we use the correct address-family-specific function for
> handling MTU reductions from within tcp_release_cb().
> 
> Previously AF_INET6 sockets were incorrectly always using the IPv6
> code path when sometimes they were handling IPv4 traffic and thus had
> an IPv4 dst.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Diagnosed-by: Willem de Bruijn <willemb@google.com>
> Fixes: 563d34d057862 ("tcp: dont drop MTU reduction indications")

Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
