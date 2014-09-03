From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 1/2] ipv6: fix a refcnt leak with peer addr
Date: Thu, 04 Sep 2014 01:43:28 +0200
Message-ID: <1409787808.3038488.163376797.2CB8674A@webmail.messagingengine.com>
References: <1409781562-4191-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	yoshfuji@linux-ipv6.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:49632 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935406AbaICXn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 19:43:29 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway2.nyi.internal (Postfix) with ESMTP id E4FAD207A7
	for <netdev@vger.kernel.org>; Wed,  3 Sep 2014 19:43:28 -0400 (EDT)
In-Reply-To: <1409781562-4191-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, Sep 3, 2014, at 23:59, Nicolas Dichtel wrote:
> There is no reason to take a refcnt before deleting the peer address
> route.
> It's done some lines below for the local prefix route because
> inet6_ifa_finish_destroy() will release it at the end.
> For the peer address route, we want to free it right now.
> 
> This bug has been introduced by commit
> caeaba79009c ("ipv6: add support of peer address").
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
