From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] udp: restore UDPlite many-cast delivery
Date: Mon, 14 Nov 2016 16:43:26 -0800
Message-ID: <1479170606.8455.112.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1479163230-8734-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
        drheld@google.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33645 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755155AbcKOAn2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 19:43:28 -0500
Received: by mail-pg0-f67.google.com with SMTP id 3so10217099pgd.0
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 16:43:28 -0800 (PST)
In-Reply-To: <1479163230-8734-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-14 at 23:40 +0100, Pablo Neira Ayuso wrote:
> Honor udptable parameter that is passed to __udp*_lib_mcast_deliver(),
> otherwise udplite broadcast/multicast use the wrong table and it breaks.
> 
> Fixes: 2dc41cff7545 ("udp: Use hash2 for long hash1 chains in __udp*_lib_mcast_deliver.")
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
> It looks like UDPlite accidentally broke when dealing with long UDP many-cast
> chains, give the wrong table is used for udplite. Compile tested only.

Good catch. Looks like some people actually use UDPlite ;)

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Pablo.
