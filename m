From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bridge: netlink: account for
 IFLA_BRPORT_{B,M}CAST_FLOOD size and policy
Date: Fri, 5 May 2017 17:55:23 +0300
Message-ID: <99166e63-9a78-60ad-7dae-98e1fd445cf1@cumulusnetworks.com>
References: <20170505143653.8486-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
        Mike Manning <mmanning@brocade.com>
To: Tobias Klauser <tklauser@distanz.ch>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36272 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752746AbdEEOzc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 10:55:32 -0400
Received: by mail-wm0-f44.google.com with SMTP id u65so26157593wmu.1
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 07:55:31 -0700 (PDT)
In-Reply-To: <20170505143653.8486-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/05/17 17:36, Tobias Klauser wrote:
> The attribute sizes for IFLA_BRPORT_MCAST_FLOOD and
> IFLA_BRPORT_BCAST_FLOOD weren't accounted for in br_port_info_size()
> when they were added. Do so now and also add the corresponding policy
> entries:
> 
> Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Cc: Mike Manning <mmanning@brocade.com>
> Fixes: b6cb5ac8331b ("net: bridge: add per-port multicast flood flag")
> Fixes: 99f906e9ad7b ("bridge: add per-port broadcast flood flag")
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  net/bridge/br_netlink.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 

Oops, good catch.

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
