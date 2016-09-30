From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6 addrconf: implement RFC7559 router solicitation
 backoff
Date: Fri, 30 Sep 2016 01:54:47 -0400 (EDT)
Message-ID: <20160930.015447.181630823844188041.davem@davemloft.net>
References: <1475045878-30455-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT
Cc: maze@google.com, netdev@vger.kernel.org, ek@google.com,
        lorenzo@google.com, hannes@stressinduktion.org,
        hideaki.yoshifuji@miraclelinux.com
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36760 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935714AbcI3FzC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 01:55:02 -0400
In-Reply-To: <1475045878-30455-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej ¯enczykowski <zenczykowski@gmail.com>
Date: Tue, 27 Sep 2016 23:57:58 -0700

> From: Maciej ¯enczykowski <maze@google.com>
> 
> This implements:
>   https://tools.ietf.org/html/rfc7559
> 
> Backoff is performed according to RFC3315 section 14:
>   https://tools.ietf.org/html/rfc3315#section-14
> 
> We allow setting /proc/sys/net/ipv6/conf/*/router_solicitations
> to a negative value meaning an unlimited number of retransmits,
> and we make this the new default (inline with the RFC).
> 
> We also add a new setting:
>   /proc/sys/net/ipv6/conf/*/router_solicitation_max_interval
> defaulting to 1 hour (per RFC recommendation).
> 
> Signed-off-by: Maciej ¯enczykowski <maze@google.com>

Applied to net-next, thanks.
