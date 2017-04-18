From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] net: ipv6: Fix UDP early demux lookup with
 udp_l3mdev_accept=0
Date: Tue, 18 Apr 2017 09:59:30 -0600
Message-ID: <60e43d02-035e-6536-4284-1c5b31c696ab@cumulusnetworks.com>
References: <1492471495-13073-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        davem@davemloft.net, netdev@vger.kernel.org, rshearma@brocade.com,
        eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:33398 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753372AbdDRP7b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 11:59:31 -0400
Received: by mail-pg0-f51.google.com with SMTP id 63so30043543pgh.0
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 08:59:31 -0700 (PDT)
In-Reply-To: <1492471495-13073-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/17/17 5:24 PM, Subash Abhinov Kasiviswanathan wrote:
> David Ahern reported that 5425077d73e0c ("net: ipv6: Add early demux
> handler for UDP unicast") breaks udp_l3mdev_accept=0 since early
> demux for IPv6 UDP was doing a generic socket lookup which does not
> require an exact match. Fix this by making UDPv6 early demux match
> connected sockets only.
> 
> v1->v2: Take reference to socket after match as suggested by Eric
> 
> Fixes: 5425077d73e0c ("net: ipv6: Add early demux handler for UDP unicast")
> Reported-by: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> Cc: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv6/udp.c | 23 ++++++++++++++---------
>  1 file changed, 14 insertions(+), 9 deletions(-)

Besides adding the comment before the break, this looks fine to me.

Acked-by: David Ahern <dsa@cumulusnetworks.com>
Tested-by: David Ahern <dsa@cumulusnetworks.com>

If the only change for v3 is the comment before the break, please keep
the above with the new patch.
