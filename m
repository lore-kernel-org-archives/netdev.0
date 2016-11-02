From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/3] ipv6: add IPV6_RECVFRAGSIZE cmsg
Date: Wed, 02 Nov 2016 08:53:12 -0700
Message-ID: <1478101992.7065.373.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1478098938-124108-1-git-send-email-willemdebruijn.kernel@gmail.com>
         <1478098938-124108-3-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jdorfman@google.com, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33236 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754544AbcKBPxO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:53:14 -0400
Received: by mail-pf0-f196.google.com with SMTP id a136so2114073pfa.0
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 08:53:14 -0700 (PDT)
In-Reply-To: <1478098938-124108-3-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-02 at 11:02 -0400, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> When reading a datagram or raw packet that arrived fragmented, expose
> the maximum fragment size if recorded to allow applications to
> estimate receive path MTU.

Acked-by: Eric Dumazet <edumazet@google.com>
