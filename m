From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] net: filter: x86: fix JIT address randomization
Date: Tue, 13 May 2014 15:19:00 -0700
Message-ID: <1400019540.7973.62.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400018755-3049-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:38125 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753326AbaEMWTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 18:19:03 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so794722pbb.5
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 15:19:02 -0700 (PDT)
In-Reply-To: <1400018755-3049-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-05-13 at 15:05 -0700, Alexei Starovoitov wrote:

> 
> Fix it by making sure that &header->image[prandom_u32() % hole] and &header
> are in the same page
> 
> Fixes: 314beb9bcabfd ("x86: bpf_jit_comp: secure bpf jit against spraying attacks")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
>  arch/x86/net/bpf_jit_comp.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Thanks Alexei.

Acked-by: Eric Dumazet <edumazet@google.com>
