From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_tunnel: Account for tunnel header in tunnel MTU
Date: Mon, 16 Jan 2017 13:23:54 -0500 (EST)
Message-ID: <20170116.132354.233406546482146773.davem@davemloft.net>
References: <1484298740-29199-1-git-send-email-jkbs@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: jkbs@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45654 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750803AbdAPSYD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 13:24:03 -0500
In-Reply-To: <1484298740-29199-1-git-send-email-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Sitnicki <jkbs@redhat.com>
Date: Fri, 13 Jan 2017 10:12:20 +0100

> With ip6gre we have a tunnel header which also makes the tunnel MTU
> smaller. We need to reserve room for it. Previously we were using up
> space reserved for the Tunnel Encapsulation Limit option
> header (RFC 2473).
> 
> Also, after commit b05229f44228 ("gre6: Cleanup GREv6 transmit path,
> call common GRE functions") our contract with the caller has
> changed. Now we check if the packet length exceeds the tunnel MTU after
> the tunnel header has been pushed, unlike before.
> 
> This is reflected in the check where we look at the packet length minus
> the size of the tunnel header, which is already accounted for in tunnel
> MTU.
> 
> Fixes: b05229f44228 ("gre6: Cleanup GREv6 transmit path, call common GRE functions")
> Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>

Applied and queued up for -stable, thanks.
