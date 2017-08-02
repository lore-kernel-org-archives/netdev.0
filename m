From: Dave Watson <davejwatson@fb.com>
Subject: Re: [PATCH v2 net-next 3/4] tcp: Adjust TCP ULP to defer to sockets
 ULP
Date: Wed, 2 Aug 2017 11:59:08 -0700
Message-ID: <20170802185908.GA47485@apz-mbp.dhcp.thefacebook.com>
References: <20170802031846.21993-1-tom@quantonium.net>
 <20170802031846.21993-4-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <rohit@quantonium.net>
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:42701 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751186AbdHBS7g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 14:59:36 -0400
Content-Disposition: inline
In-Reply-To: <20170802031846.21993-4-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/17 08:18 PM, Tom Herbert wrote:
> Fix TCP and TLS to use the newer ULP infrastructure in sockets.
> 
> Signed-off-by: Tom Herbert <tom@quantonium.net>
> ---
>  Documentation/networking/tls.txt   |   6 +-
>  include/net/inet_connection_sock.h |   4 --
>  include/net/tcp.h                  |  25 -------
>  include/net/tls.h                  |   4 +-
>  net/ipv4/sysctl_net_ipv4.c         |   9 ++-
>  net/ipv4/tcp.c                     |  40 ++++++-----
>  net/ipv4/tcp_ipv4.c                |   2 -
>  net/ipv4/tcp_ulp.c                 | 135 -------------------------------------
>  net/tls/Kconfig                    |   1 +
>  net/tls/tls_main.c                 |  21 +++---
>  10 files changed, 47 insertions(+), 200 deletions(-)
>  delete mode 100644 net/ipv4/tcp_ulp.c

It looks like net/ipv4/Makefile needs updating as well.

I ran this through some ktls tests with no issues.  Thanks

Tested-by: Dave Watson <davejwatson@fb.com>
