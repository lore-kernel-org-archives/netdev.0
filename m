From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next v2 1/4] packet: add classic BPF fanout mode
Date: Sat, 15 Aug 2015 21:58:23 -0700
Message-ID: <55D0186F.7080906@plumgrid.com>
References: <1439605897-28311-1-git-send-email-willemb@google.com>
 <1439605897-28311-2-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, daniel@iogearbox.net
To: Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:35005 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbbHPE60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Aug 2015 00:58:26 -0400
Received: by pdrg1 with SMTP id g1so44096198pdr.2
        for <netdev@vger.kernel.org>; Sat, 15 Aug 2015 21:58:25 -0700 (PDT)
In-Reply-To: <1439605897-28311-2-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/14/15 7:31 PM, Willem de Bruijn wrote:
> From: Willem de Bruijn<willemb@google.com>
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
> Signed-off-by: Willem de Bruijn<willemb@google.com>

bpf bits looks good.
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
