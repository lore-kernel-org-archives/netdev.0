From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v2 PATCH 10/11] xfrm: Stop using dst->next in bundle
 construction.
Date: Tue, 31 Oct 2017 11:52:26 -0700
Message-ID: <1509475946.3828.37.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171031141054.9954-1-davem@davemloft.net>
         <20171031141054.9954-11-davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:47968 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932583AbdJaSw3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:52:29 -0400
Received: by mail-io0-f195.google.com with SMTP id h70so1014842ioi.4
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:52:29 -0700 (PDT)
In-Reply-To: <20171031141054.9954-11-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-31 at 23:10 +0900, David S. Miller wrote:
> While building ipsec bundles, blocks of xfrm dsts are linked together
> using dst->next from bottom to the top.
> 
> The only thing this is used for is initializing the pmtu values of the
> xfrm stack, and for updating the mtu values at xfrm_bundle_ok() time.
> 
> The bundle pmtu entries must be processed in this order so that pmtu
> values lower in the stack of routes can propagate up to the higher
> ones.
> 
> Avoid using dst->next by simply maintaining an array of dst pointers
> as we already do for the xfrm_state objects when building the bundle.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

Reviewed-by: Eric Dumazet <edumazet@google.com>
