From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next v2] bpf: add support for generic xdp
Date: Mon, 1 May 2017 09:29:15 -0700
Message-ID: <20170501092915.5c19395c@xeon-e3>
References: <e2ca217f7b95b4dd0b5fa8650e8fcf783de73967.1493386943.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, davem@davemloft.net,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:35993 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752643AbdEAQ3S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 12:29:18 -0400
Received: by mail-pg0-f49.google.com with SMTP id t7so46980394pgt.3
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 09:29:17 -0700 (PDT)
In-Reply-To: <e2ca217f7b95b4dd0b5fa8650e8fcf783de73967.1493386943.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Apr 2017 15:44:29 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

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

Applied, thanks for remembering to update man page.
Does bash-completion need update?
