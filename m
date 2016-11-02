From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] ipv6: on reassembly, record frag_max_size
Date: Wed, 02 Nov 2016 08:55:25 -0700
Message-ID: <1478102125.7065.374.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1478098938-124108-1-git-send-email-willemdebruijn.kernel@gmail.com>
         <1478098938-124108-4-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jdorfman@google.com, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35192 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753150AbcKBPz1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:55:27 -0400
Received: by mail-pf0-f193.google.com with SMTP id i88so2111203pfk.2
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 08:55:27 -0700 (PDT)
In-Reply-To: <1478098938-124108-4-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-02 at 11:02 -0400, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> IP6CB and IPCB have a frag_max_size field. In IPv6 this field is
> filled in when packets are reassembled by the connection tracking
> code. Also fill in when reassembling in the input path, to expose
> it through cmsg IPV6_RECVFRAGSIZE in all cases.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
