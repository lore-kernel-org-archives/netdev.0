From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 0/2] net: ubuf_info.refcnt conversion
Date: Thu, 31 Aug 2017 17:04:55 -0700
Message-ID: <1504224295.15310.17.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170831234822.26612-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33590 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751242AbdIAAE5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 20:04:57 -0400
Received: by mail-pg0-f65.google.com with SMTP id m15so708189pgc.0
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 17:04:57 -0700 (PDT)
In-Reply-To: <20170831234822.26612-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-08-31 at 16:48 -0700, Eric Dumazet wrote:
> Yet another atomic_t -> refcount_t conversion, split in two patches.
> 
> First patch prepares the automatic conversion done in the second patch.
> 
> Eric Dumazet (2):
>   net: prepare (struct ubuf_info)->refcnt conversion
>   net: convert (struct ubuf_info)->refcnt to refcount_t
> 
>  drivers/vhost/net.c    |  2 +-
>  include/linux/skbuff.h |  5 +++--
>  net/core/skbuff.c      | 14 ++++----------
>  net/ipv4/tcp.c         |  2 --
>  4 files changed, 8 insertions(+), 15 deletions(-)
> 

David please ignore this series, I will send a V3 :)
