From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 2/2] packet: round up linear to header len
Date: Tue, 07 Feb 2017 13:23:51 -0800
Message-ID: <1486502631.7793.68.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170207205721.23207-1-willemdebruijn.kernel@gmail.com>
         <20170207205721.23207-3-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        sowmini.varadhan@oracle.com, dvyukov@google.com,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36131 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754367AbdBGVaP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 16:30:15 -0500
Received: by mail-pg0-f65.google.com with SMTP id 75so13099207pgf.3
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 13:30:15 -0800 (PST)
In-Reply-To: <20170207205721.23207-3-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-02-07 at 15:57 -0500, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> Link layer protocols may unconditionally pull headers, as Ethernet
> does in eth_type_trans. Ensure that the entire link layer header
> always lies in the skb linear segment. tpacket_snd has such a check.
> Extend this to packet_snd.
> 
> Variable length link layer headers complicate the computation
> somewhat. Here skb->len may be smaller than dev->hard_header_len.
> 
> Round up the linear length to be at least as long as the smallest of
> the two.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
