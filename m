From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v2 PATCH 07/11] ipv6: Move dst->from into struct rt6_info.
Date: Tue, 31 Oct 2017 11:47:05 -0700
Message-ID: <1509475625.3828.34.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171031141054.9954-1-davem@davemloft.net>
         <20171031141054.9954-8-davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:45425 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751641AbdJaSrH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:47:07 -0400
Received: by mail-pg0-f67.google.com with SMTP id b192so15425715pga.2
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:47:07 -0700 (PDT)
In-Reply-To: <20171031141054.9954-8-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-31 at 23:10 +0900, David S. Miller wrote:
> The dst->from value is only used by ipv6 routes to track where
> a route "came from".
> 
> Any time we clone or copy a core ipv6 route in the ipv6 routing
> tables, we have the copy/clone's ->from point to the base route.
> 
> This is used to handle route expiration properly.
> 
> Only ipv6 uses this mechanism, and only ipv6 code references
> it.  So it is safe to move it into rt6_info.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

Reviewed-by: Eric Dumazet <edumazet@google.com>
