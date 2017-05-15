From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] net/sock: factor out dequeue/peek with
 offset code
Date: Mon, 15 May 2017 09:02:18 -0700
Message-ID: <1494864138.6465.0.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1494837879.git.pabeni@redhat.com>
         <503e324ecd4085f256474df1a352a92814fd29f4.1494837879.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35679 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935060AbdEOQCV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 12:02:21 -0400
Received: by mail-pf0-f196.google.com with SMTP id u26so16240144pfd.2
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 09:02:21 -0700 (PDT)
In-Reply-To: <503e324ecd4085f256474df1a352a92814fd29f4.1494837879.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-15 at 11:01 +0200, Paolo Abeni wrote:
> And update __sk_queue_drop_skb() to work on the specified queue.
> This will help the udp protocol to use an additional private
> rx queue in a later patch.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
