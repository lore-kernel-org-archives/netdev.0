From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] net: updates for IPv6 Segment Routing
Date: Fri, 25 Aug 2017 17:10:47 -0700 (PDT)
Message-ID: <20170825.171047.1935113010419428511.davem@davemloft.net>
References: <20170825075648.5061-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36828 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751411AbdHZAKs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 20:10:48 -0400
In-Reply-To: <20170825075648.5061-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Fri, 25 Aug 2017 09:56:43 +0200

> v2: seg6_lwt_headroom() is not relevant for lwtunnel_input_redirect()
>     use cases, and L2ENCAP only uses this redirection. Fix incoherence
>     between arbitrary MAC header size support and fixed headroom
>     computation by setting only LWTUNNEL_STATE_INPUT_REDIRECT for L2ENCAP
>     mode.
> 
> This patch series provides several updates for the SRv6 implementation. The
> first patch leverages the existing infrastructure to support encapsulation
> of IPv4 packets. The second patch implements the T.Encaps.L2 SR function,
> enabling to encapsulate an L2 Ethernet frame within an IPv6+SRH packet.
> The last three patches update the seg6local lightweight tunnel, and mainly
> implement four new actions: End.T, End.DX2, End.DX4 and End.DT6.

Series applied, thanks.
