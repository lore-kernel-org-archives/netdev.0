From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: release dst on error in ip6_dst_lookup_tail
Date: Sat, 18 Feb 2017 15:56:47 -0800
Message-ID: <1487462207.1311.107.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170218235144.29670-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jtleight@udel.edu,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34576 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750760AbdBRX4v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 18:56:51 -0500
Received: by mail-pf0-f196.google.com with SMTP id o64so6882076pfb.1
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 15:56:50 -0800 (PST)
In-Reply-To: <20170218235144.29670-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-02-18 at 18:51 -0500, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> If ip6_dst_lookup_tail has acquired a dst and fails the IPv4-mapped
> check, release the dst before returning an error.
> 
> Fixes: b2e6f0c8dde5 ("ipv6: Inhibit IPv4-mapped src address on the wire.")
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

But looks like the commit sha1 was
ec5e3b0a1d41fbda0cc33a45bc9e54e91d9d12c7

So the correct tag would be

Fixes: ec5e3b0a1d41 ("ipv6: Inhibit IPv4-mapped src address on the wire.")
