From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] ipv6: release dst on error in ip6_dst_lookup_tail
Date: Sat, 18 Feb 2017 16:26:40 -0800
Message-ID: <1487464000.1311.110.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170219000045.34672-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jtleight@udel.edu,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34080 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750812AbdBSA0n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 19:26:43 -0500
Received: by mail-pf0-f193.google.com with SMTP id o64so6913564pfb.1
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 16:26:43 -0800 (PST)
In-Reply-To: <20170219000045.34672-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-02-18 at 19:00 -0500, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> If ip6_dst_lookup_tail has acquired a dst and fails the IPv4-mapped
> check, release the dst before returning an error.
> 
> Fixes: ec5e3b0a1d41 ("ipv6: Inhibit IPv4-mapped src address on the wire.")
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
Acked-by: Eric Dumazet <edumazet@google.com>
