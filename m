From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/2] net: introduce device min_header_len
Date: Tue, 07 Feb 2017 13:20:18 -0800
Message-ID: <1486502418.7793.67.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170207205721.23207-1-willemdebruijn.kernel@gmail.com>
         <20170207205721.23207-2-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        sowmini.varadhan@oracle.com, dvyukov@google.com,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33056 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754414AbdBGVVa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 16:21:30 -0500
Received: by mail-pf0-f196.google.com with SMTP id e4so10032453pfg.0
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 13:20:20 -0800 (PST)
In-Reply-To: <20170207205721.23207-2-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-02-07 at 15:57 -0500, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> The stack must not pass packets to device drivers that are shorter
> than the minimum link layer header length.
> 
> Previously, packet sockets would drop packets smaller than or equal
> to dev->hard_header_len, but this has false positives. Zero length
> payload is used over Ethernet. Other link layer protocols support
> variable length headers. Support for validation of these protocols
> removed the min length check for all protocols.
> 
> Introduce an explicit dev->min_header_len parameter and drop all
> packets below this value. Initially, set it to non-zero only for
> Ethernet and loopback. Other protocols can follow in a patch to
> net-next.
> 
> Fixes: 9ed988cd5915 ("packet: validate variable length ll headers")
> Reported-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
