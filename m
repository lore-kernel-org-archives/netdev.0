From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH iproute2 net-next v2] bpf: add support for generic xdp
Date: Fri, 28 Apr 2017 10:21:58 -0400 (EDT)
Message-ID: <20170428.102158.1626837672156739210.davem@davemloft.net>
References: <e2ca217f7b95b4dd0b5fa8650e8fcf783de73967.1493386943.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54670 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031362AbdD1OWA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 10:22:00 -0400
In-Reply-To: <e2ca217f7b95b4dd0b5fa8650e8fcf783de73967.1493386943.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 28 Apr 2017 15:44:29 +0200

> Follow-up to commit c7272ca72009 ("bpf: add initial support for
> attaching xdp progs") to also support generic XDP. This adds an
> indicator for loaded generic XDP programs when programs are loaded
> as shown in c7272ca72009, but the driver still lacks native XDP
> support.
> 
>   # ip link
>   [...]
>   3: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 xdpgeneric qdisc [...]
>       link/ether 0c:c4:7a:03:f9:25 brd ff:ff:ff:ff:ff:ff
>   [...]
> 
> In case the driver does support native XDP, but the user wants
> to load the program as generic XDP (e.g. for testing purposes),
> then this can be done with the same semantics as in c7272ca72009,
> but with 'xdpgeneric' instead of 'xdp' command for loading:
> 
>   # ip -force link set dev eno1 xdpgeneric obj xdp.o
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: David S. Miller <davem@davemloft.net>
