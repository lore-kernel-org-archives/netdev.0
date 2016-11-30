From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6 addrconf: Implemented enhanced DAD
 (RFC7527)
Date: Wed, 30 Nov 2016 10:58:06 -0500 (EST)
Message-ID: <20161130.105806.461585801662945197.davem@davemloft.net>
References: <20161128060811.1E49FD341C60@us153.sjc.aristanetworks.com>
        <4936dca6-c55d-809e-a032-f78e23ce6b49@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org, gilligan@arista.com,
        hannes@stressinduktion.org
To: nordmark@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34206 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751038AbcK3P6K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 10:58:10 -0500
In-Reply-To: <4936dca6-c55d-809e-a032-f78e23ce6b49@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Nordmark <nordmark@arista.com>
Date: Mon, 28 Nov 2016 15:26:05 -0800

> Implemented RFC7527 Enhanced DAD.
> IPv6 duplicate address detection can fail if there is some temporary
> loopback of Ethernet frames. RFC7527 solves this by including a random
> nonce in the NS messages used for DAD, and if an NS is received with
> the
> same nonce it is assumed to be a looped back DAD probe and is ignored.
> RFC7527 is enabled by default. Can be disabled by setting both of
> conf/{all,interface}/enhanced_dad to zero.
> 
> Signed-off-by: Erik Nordmark<nordmark@arista.com>
> Signed-off-by: Bob Gilligan<gilligan@arista.com>"
> ---
> 
> v2: renamed sysctl and made it default to true, plus minor code review
> fixes

This doesn't apply to net-next, please respin.

Also, please format your signoffs correctly, there must be a space
between your name and the <> enclosed email address.

I always wonder why people elide spaces when formatting text, is
there a global shortage of space characters that I am unaware of?
