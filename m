From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/4] packet: add BPF fanout mode
Date: Mon, 17 Aug 2015 07:29:02 -0700
Message-ID: <1439821742.7258.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439567427-19504-1-git-send-email-willemb@google.com>
	 <1439567427-19504-2-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	dborkman@redhat.com, ast@plumgrid.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:36041 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755304AbbHQP0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 11:26:14 -0400
Received: by pdbmi9 with SMTP id mi9so16415428pdb.3
        for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 08:26:14 -0700 (PDT)
In-Reply-To: <1439567427-19504-2-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-08-14 at 11:50 -0400, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> Add a fanout mode that accepts a BPF program to select a socket.
> 
> This avoids having to keep adding special case fanout modes. One
> example use case is application layer load balancing. The QUIC
> protocol, for instance, encodes a connection ID in UDP payload.
> 
> Also add socket option SOL_PACKET/PACKET_FANOUT_DATA that updates data
> associated with the socket group. Fanout mode PACKET_FANOUT_BPF is the
> only user so far.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com

Acked-by: Eric Dumazet <edumazet@google.com>
