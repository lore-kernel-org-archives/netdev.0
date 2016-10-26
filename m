From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] packet: on direct_xmit, limit tso and csum to
 supported devices
Date: Wed, 26 Oct 2016 09:14:53 -0700
Message-ID: <1477498493.7065.185.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1477495387-36861-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, daniel@iogearbox.net,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33478 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751583AbcJZQO4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 12:14:56 -0400
Received: by mail-pf0-f193.google.com with SMTP id i85so23168688pfa.0
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 09:14:55 -0700 (PDT)
In-Reply-To: <1477495387-36861-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-10-26 at 11:23 -0400, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> When transmitting on a packet socket with PACKET_VNET_HDR and
> PACKET_QDISC_BYPASS, validate device support for features requested
> in vnet_hdr.

Acked-by: Eric Dumazet <edumazet@google.com>
