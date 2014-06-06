From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] net: filter: fix typo in sparc BPF JIT
Date: Fri, 06 Jun 2014 18:11:19 +0400
Message-ID: <5391CC07.4000002@cogentembedded.com>
References: <1402033664-14551-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:36868 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477AbaFFOLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 10:11:08 -0400
Received: by mail-lb0-f171.google.com with SMTP id 10so1580389lbg.30
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 07:11:07 -0700 (PDT)
In-Reply-To: <1402033664-14551-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/06/2014 09:47 AM, Alexei Starovoitov wrote:

> fix typo in sparc codegen for SKF_AD_IFINDEX and SKF_AD_HATYPE
> classic BPF extensions

> Fixes: 2809a2087cc4 ("net: filter: Just In Time compiler for sparc")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> tested with qemu-sparc64
> the patch doesn't apply cleanly to net-next, but logic is the same.

>   arch/sparc/net/bpf_jit_comp.c |    8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)

> diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
> index a82c6b2..b19a0c2 100644
> --- a/arch/sparc/net/bpf_jit_comp.c
> +++ b/arch/sparc/net/bpf_jit_comp.c
> @@ -83,9 +83,9 @@ static void bpf_flush_icache(void *start_, void *end_)
>   #define BNE		(F2(0, 2) | CONDNE)
>
>   #ifdef CONFIG_SPARC64
> -#define BNE_PTR		(F2(0, 1) | CONDNE | (2 << 20))
> +#define BE_PTR		(F2(0, 1) | CONDE | (2 << 20))
>   #else
> -#define BNE_PTR		BNE
> +#define BE_PTR		BNE

    BNE, not BE?

WBR, Sergei
