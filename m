From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v2 1/4] packet: add classic BPF fanout mode
Date: Sun, 16 Aug 2015 11:15:08 +0200
Message-ID: <55D0549C.5040104@iogearbox.net>
References: <1439605897-28311-1-git-send-email-willemb@google.com> <1439605897-28311-2-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, ast@plumgrid.com
To: Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36065 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089AbbHPJPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Aug 2015 05:15:12 -0400
In-Reply-To: <1439605897-28311-2-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2015 04:31 AM, Willem de Bruijn wrote:
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

Patch looks good to me as well (sorry for the lag, on travel).

Thanks Willem!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
