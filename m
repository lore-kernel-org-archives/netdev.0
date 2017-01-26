From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: ipv6: remove skb_reserve in getroute
Date: Thu, 26 Jan 2017 14:29:33 -0800
Message-ID: <1485469773.5145.178.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485468516-4750-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33428 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751957AbdAZWbT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 17:31:19 -0500
Received: by mail-pg0-f65.google.com with SMTP id 194so23343748pgd.0
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 14:29:35 -0800 (PST)
In-Reply-To: <1485468516-4750-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-26 at 14:08 -0800, David Ahern wrote:
> Remove skb_reserve and skb_reset_mac_header from inet6_rtm_getroute. The
> allocated skb is not passed through the routing engine (like it is for
> IPv4) and has not since the beginning of git time.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  net/ipv6/route.c | 6 ------
>  1 file changed, 6 deletions(-)

Nice ;)

Acked-by: Eric Dumazet <edumazet@google.com>
