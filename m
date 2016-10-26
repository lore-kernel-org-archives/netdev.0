From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] packet: on direct_xmit, limit tso and csum to
 supported devices
Date: Tue, 25 Oct 2016 17:57:31 -0700
Message-ID: <1477443451.7065.163.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1477441683-68242-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, daniel@iogearbox.net,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34291 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752238AbcJZA5e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 20:57:34 -0400
Received: by mail-pf0-f195.google.com with SMTP id u84so637208pfj.1
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 17:57:34 -0700 (PDT)
In-Reply-To: <1477441683-68242-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-10-25 at 20:28 -0400, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> When transmitting on a packet socket with PACKET_VNET_HDR and
> PACKET_QDISC_BYPASS, validate device support for features requested
> in vnet_hdr.


You probably need to add an EXPORT_SYMBOL(validate_xmit_skb_list)
because af_packet might be modular.

Sorry for not catching this earlier.
