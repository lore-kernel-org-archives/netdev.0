From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_tunnel: disable caching when the traffic class
 is inherited
Date: Thu, 17 Nov 2016 12:09:40 -0500 (EST)
Message-ID: <20161117.120940.1678961893613466136.davem@davemloft.net>
References: <67662ec875375c86e95666a7e47fc61c3a869d86.1479309929.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, liam.mcbirnie@boeing.com,
        hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39916 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754415AbcKQRJl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 12:09:41 -0500
In-Reply-To: <67662ec875375c86e95666a7e47fc61c3a869d86.1479309929.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Wed, 16 Nov 2016 16:26:46 +0100

> If an ip6 tunnel is configured to inherit the traffic class from
> the inner header, the dst_cache must be disabled or it will foul
> the policy routing.
> 
> The issue is apprently there since at leat Linux-2.6.12-rc2.
> 
> Reported-by: Liam McBirnie <liam.mcbirnie@boeing.com>
> Cc: Liam McBirnie <liam.mcbirnie@boeing.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied and queued up for -stable, thank you.
