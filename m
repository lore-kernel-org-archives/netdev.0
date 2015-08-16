From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next v2 2/4] packet: add extended BPF fanout mode
Date: Sat, 15 Aug 2015 21:58:41 -0700
Message-ID: <55D01881.1010004@plumgrid.com>
References: <1439605897-28311-1-git-send-email-willemb@google.com>
 <1439605897-28311-3-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, daniel@iogearbox.net
To: Willem de Bruijn <willemb@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34980 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbbHPE6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Aug 2015 00:58:43 -0400
Received: by pacgr6 with SMTP id gr6so85190195pac.2
        for <netdev@vger.kernel.org>; Sat, 15 Aug 2015 21:58:43 -0700 (PDT)
In-Reply-To: <1439605897-28311-3-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/14/15 7:31 PM, Willem de Bruijn wrote:
> From: Willem de Bruijn<willemb@google.com>
>
> Add fanout mode PACKET_FANOUT_EBPF that accepts an en extended BPF
> program to select a socket.
>
> Update the internal eBPF program by passing to socket option
> SOL_PACKET/PACKET_FANOUT_DATA a file descriptor returned by bpf().
>
> Signed-off-by: Willem de Bruijn<willemb@google.com>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
