From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v2 2/4] packet: add extended BPF fanout mode
Date: Sun, 16 Aug 2015 11:15:33 +0200
Message-ID: <55D054B5.9030706@iogearbox.net>
References: <1439605897-28311-1-git-send-email-willemb@google.com> <1439605897-28311-3-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, ast@plumgrid.com
To: Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36099 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244AbbHPJPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Aug 2015 05:15:35 -0400
In-Reply-To: <1439605897-28311-3-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2015 04:31 AM, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> Add fanout mode PACKET_FANOUT_EBPF that accepts an en extended BPF
> program to select a socket.
>
> Update the internal eBPF program by passing to socket option
> SOL_PACKET/PACKET_FANOUT_DATA a file descriptor returned by bpf().
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
