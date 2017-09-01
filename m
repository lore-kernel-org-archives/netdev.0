From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v5 2/2] tcp_diag: report TCP MD5 signing keys
 and addresses
Date: Thu, 31 Aug 2017 19:58:49 -0700
Message-ID: <1504234729.15310.20.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170831165939.5121-1-colona@arista.com>
         <20170831165939.5121-3-colona@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ivan Delalande <colona@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:38749 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751346AbdIAC6v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 22:58:51 -0400
Received: by mail-pf0-f196.google.com with SMTP id r187so843577pfr.5
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 19:58:51 -0700 (PDT)
In-Reply-To: <20170831165939.5121-3-colona@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-08-31 at 09:59 -0700, Ivan Delalande wrote:
> Report TCP MD5 (RFC2385) signing keys, addresses and address prefixes to
> processes with CAP_NET_ADMIN requesting INET_DIAG_INFO. Currently it is
> not possible to retrieve these from the kernel once they have been
> configured on sockets.
> 
> Signed-off-by: Ivan Delalande <colona@arista.com>
> ---
>  include/uapi/linux/inet_diag.h |   1 +
>  include/uapi/linux/tcp.h       |   9 ++++
>  net/ipv4/tcp_diag.c            | 109 ++++++++++++++++++++++++++++++++++++++---
>  3 files changed, 113 insertions(+), 6 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
