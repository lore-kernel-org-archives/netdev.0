From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH net] sit: Set skb->protocol properly in
 ipip6_tunnel_xmit()
Date: Sun, 27 Nov 2016 13:04:00 +1100
Message-ID: <20161127130400.4a69ff1b@canb.auug.org.au>
References: <20161125055017.7053-1-elicooper@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
To: Eli Cooper <elicooper@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:37315 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752505AbcK0CEt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 26 Nov 2016 21:04:49 -0500
In-Reply-To: <20161125055017.7053-1-elicooper@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eli,

[Just for Dave's information]

On Fri, 25 Nov 2016 13:50:17 +0800 Eli Cooper <elicooper@gmx.com> wrote:
>
> Similar to commit ae148b085876
> ("ip6_tunnel: Update skb->protocol to ETH_P_IPV6 in ip6_tnl_xmit()"),
> sit tunnels also need to update skb->protocol; otherwise, TSO/GSO packets
> might not be properly segmented, which causes the packets being dropped.
> 
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Tested-by: Eli Cooper <elicooper@gmx.com>
> Cc: stable@vger.kernel.org
> Signed-off-by: Eli Cooper <elicooper@gmx.com>

I tested this patch and it does *not* solve my problem.

-- 
Cheers,
Stephen Rothwell
