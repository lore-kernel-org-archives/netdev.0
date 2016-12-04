From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] ipv6 addrconf: Implemented enhanced DAD
 (RFC7527)
Date: Sat, 03 Dec 2016 23:26:09 -0500 (EST)
Message-ID: <20161203.232609.1047902442344574211.davem@davemloft.net>
References: <1480716008-11646-1-git-send-email-nordmark@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
        gilligan@arista.com
To: nordmark@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42088 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752128AbcLDE0L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 23:26:11 -0500
In-Reply-To: <1480716008-11646-1-git-send-email-nordmark@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Nordmark <nordmark@arista.com>
Date: Fri,  2 Dec 2016 14:00:08 -0800

> Implemented RFC7527 Enhanced DAD.
> IPv6 duplicate address detection can fail if there is some temporary
> loopback of Ethernet frames. RFC7527 solves this by including a random
> nonce in the NS messages used for DAD, and if an NS is received with the
> same nonce it is assumed to be a looped back DAD probe and is ignored.
> RFC7527 is enabled by default. Can be disabled by setting both of
> conf/{all,interface}/enhanced_dad to zero.
> 
> Signed-off-by: Erik Nordmark <nordmark@arista.com>
> Signed-off-by: Bob Gilligan <gilligan@arista.com>
> Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks.
