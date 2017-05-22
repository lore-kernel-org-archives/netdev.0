From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] kernel: bpf: remove dead code
Date: Mon, 22 May 2017 19:00:14 +0200
Message-ID: <5923191E.30804@iogearbox.net>
References: <20170522140746.GA10113@embeddedgus>        <20170522.103800.1354089494827582585.davem@davemloft.net>       <5922FB28.5070303@iogearbox.net> <20170522.122742.1326733219925627993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: garsilva@embeddedor.com, ast@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38094 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759979AbdEVRAW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 13:00:22 -0400
In-Reply-To: <20170522.122742.1326733219925627993.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2017 06:27 PM, David Miller wrote:
[...]
> Ok I understand the issue now.  Thanks for explaining.
>
> I guess a hard-coded value of 2 and an adjusted comment above the
> assignment of ip_align is the way to go.
>
> I'll push the following, thanks everyone:
>
> ====================
> net: Make IP alignment calulations clearer.
>
> The assignmnet:
>
> 	ip_align = strict ? 2 : NET_IP_ALIGN;
>
> in compare_pkt_ptr_alignment() trips up Coverity because we can only
> get to this code when strict is true, therefore ip_align will always
> be 2 regardless of NET_IP_ALIGN's value.
>
> So just assign directly to '2' and explain the situation in the
> comment above.
>
> Reported-by: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Yeah, that's fine, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
