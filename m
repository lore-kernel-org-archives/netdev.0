From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Mon, 23 Jan 2017 11:15:09 -0800
Message-ID: <1485198909.16328.211.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170123185922.48046-1-tracywwnj@gmail.com>
         <20170123185922.48046-4-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>, Wei Wang <weiwan@google.com>
To: Wei Wang <tracywwnj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34471 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdAWTP4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 14:15:56 -0500
Received: by mail-pg0-f65.google.com with SMTP id t6so14418029pgt.1
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 11:15:11 -0800 (PST)
In-Reply-To: <20170123185922.48046-4-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-23 at 10:59 -0800, Wei Wang wrote:
> From: Wei Wang <weiwan@google.com>
> 
> This patch adds a new socket option, TCP_FASTOPEN_CONNECT, as an
> alternative way to perform Fast Open on the active side (client). Prior
> to this patch, a client needs to replace the connect() call with
> sendto(MSG_FASTOPEN). This can be cumbersome for applications who want
> to use Fast Open: these socket operations are often done in lower layer
> libraries used by many other applications. Changing these libraries
> and/or the socket call sequences are not trivial. A more convenient
> approach is to perform Fast Open by simply enabling a socket option when
> the socket is created w/o changing other socket calls sequence:

> Signed-off-by: Wei Wang <weiwan@google.com>
> ---

Thanks for this hard work Wei.

Acked-by: Eric Dumazet <edumazet@google.com>
