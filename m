From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 net-next] bpf: add support for generic xdp
Date: Fri, 28 Apr 2017 15:38:42 +0200
Message-ID: <590345E2.7090907@iogearbox.net>
References: <ebe1a4b9674922b8baa2b262c9d039407f047175.1493375407.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, davem@davemloft.net,
        netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38390 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2997988AbdD1NjB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 09:39:01 -0400
In-Reply-To: <ebe1a4b9674922b8baa2b262c9d039407f047175.1493375407.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/28/2017 12:42 PM, Daniel Borkmann wrote:
> Follow-up to commit c7272ca72009 ("bpf: add initial support for
> attaching xdp progs") to also support generic XDP. This adds an
> indicator for loaded generic XDP programs when programs are loaded
> as shown in c7272ca72009, but the driver still lacks native XDP
> support.
>
>    # ip link
>    [...]
>    3: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 xdpgeneric qdisc [...]
>        link/ether 0c:c4:7a:03:f9:25 brd ff:ff:ff:ff:ff:ff
>    [...]
>
> In case the driver does support native XDP, but the user wants
> to load the program as generic XDP (e.g. for testing purposes),
> then this can be done with the same semantics as in c7272ca72009,
> but with 'xdpgeneric' instead of 'xdp' command for loading:
>
>    # ip -force link set dev eno1 xdpgeneric obj xdp.o
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>   ( Requires a header update to pull in XDP_FLAGS_SKB_MODE. )

Scratch that, will send a v2 shortly.
