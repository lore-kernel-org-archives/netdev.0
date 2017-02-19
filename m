From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipv6: release dst on error in
 ip6_dst_lookup_tail
Date: Sat, 18 Feb 2017 22:55:27 -0500 (EST)
Message-ID: <20170218.225527.2206573820186151295.davem@davemloft.net>
References: <20170219000045.34672-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jtleight@udel.edu,
        willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37832 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751012AbdBSDzc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 22:55:32 -0500
In-Reply-To: <20170219000045.34672-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Sat, 18 Feb 2017 19:00:45 -0500

> From: Willem de Bruijn <willemb@google.com>
> 
> If ip6_dst_lookup_tail has acquired a dst and fails the IPv4-mapped
> check, release the dst before returning an error.
> 
> Fixes: ec5e3b0a1d41 ("ipv6: Inhibit IPv4-mapped src address on the wire.")
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thanks Willem.
