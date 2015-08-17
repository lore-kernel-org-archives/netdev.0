From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 1/4] packet: add classic BPF fanout mode
Date: Mon, 17 Aug 2015 07:29:46 -0700
Message-ID: <1439821786.7258.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439605897-28311-1-git-send-email-willemb@google.com>
	 <1439605897-28311-2-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	daniel@iogearbox.net, ast@plumgrid.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35075 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbbHQO3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 10:29:49 -0400
Received: by pacgr6 with SMTP id gr6so109794306pac.2
        for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 07:29:49 -0700 (PDT)
In-Reply-To: <1439605897-28311-2-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-08-14 at 22:31 -0400, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> Add fanout mode PACKET_FANOUT_CBPF that accepts a classic BPF program
> to select a socket.
> 
> This avoids having to keep adding special case fanout modes. One
> example use case is application layer load balancing. The QUIC
> protocol, for instance, encodes a connection ID in UDP payload.
> 
> Also add socket option SOL_PACKET/PACKET_FANOUT_DATA that updates data
> associated with the socket group. Fanout mode PACKET_FANOUT_CBPF is the
> only user so far.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---

Oops, this was the patch I meant to approve

Acked-by: Eric Dumazet <edumazet@google.com>
