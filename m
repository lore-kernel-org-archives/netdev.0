From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: factor out a helper to decrement the
 skb refcount
Date: Wed, 31 May 2017 09:56:16 -0700
Message-ID: <1496249776.27480.4.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1496070490.git.pabeni@redhat.com>
         <d8ae2b225a566fb1addf970db79cbcea834b4ad0.1496070490.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34430 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751011AbdEaQ4S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 12:56:18 -0400
Received: by mail-pg0-f68.google.com with SMTP id u13so268207pgb.1
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 09:56:18 -0700 (PDT)
In-Reply-To: <d8ae2b225a566fb1addf970db79cbcea834b4ad0.1496070490.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-29 at 17:27 +0200, Paolo Abeni wrote:
> The same code is replicated in 3 different places; move it to a
> common helper.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
