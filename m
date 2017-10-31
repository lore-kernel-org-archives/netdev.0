From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v2 PATCH 08/11] xfrm: Move dst->path into struct xfrm_dst
Date: Tue, 31 Oct 2017 11:49:05 -0700
Message-ID: <1509475745.3828.35.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171031141054.9954-1-davem@davemloft.net>
         <20171031141054.9954-9-davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:55764 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932532AbdJaStH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:49:07 -0400
Received: by mail-io0-f174.google.com with SMTP id p186so928716ioe.12
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:49:07 -0700 (PDT)
In-Reply-To: <20171031141054.9954-9-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-31 at 23:10 +0900, David S. Miller wrote:
> The first member of an IPSEC route bundle chain sets it's dst->path to
> the underlying ipv4/ipv6 route that carries the bundle.
> 
> Stated another way, if one were to follow the xfrm_dst->child chain of
> the bundle, the final non-NULL pointer would be the path and point to
> either an ipv4 or an ipv6 route.
> 
> This is largely used to make sure that PMTU events propagate down to
> the correct ipv4 or ipv6 route.
> 
> When we don't have the top of an IPSEC bundle 'dst->path == dst'.
> 
> Move it down into xfrm_dst and key off of dst->xfrm.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

Reviewed-by: Eric Dumazet <edumazet@google.com>
