From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] tools: bpf_dbg: register misuse
Date: Mon, 28 Apr 2014 10:49:08 +0200
Message-ID: <535E1604.2090404@redhat.com>
References: <CA+Z8YJKFhGQ5QPjMS6PHZnDpGJ7osrCJGDw+AMAPMckKiB8EDQ@mail.gmail.com> <CAADnVQLC305rLy6CObSgUBfwRoAMKLqc8kwO1181_oNEB1XMRw@mail.gmail.com> <CA+Z8YJL3zEz1n1ayhSWQRRSxiL__97RciQOWhLGT2VjjdqT0Lg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Brendan Hickey <bhickey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19530 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752357AbaD1ItN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 04:49:13 -0400
In-Reply-To: <CA+Z8YJL3zEz1n1ayhSWQRRSxiL__97RciQOWhLGT2VjjdqT0Lg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/25/2014 11:23 PM, Brendan Hickey wrote:
> From: Brendan Hickey <bhickey@google.com>
> Date: Fri, 25 Apr 2014 17:22:52 -0400
> Subject: [PATCH] bpf_dbg: Fix erroneous register use for AND
>
> The AND instruction is erroneously using the X register instead of the K
> register.
>
> Signed-off-by: Brendan Hickey <bhickey@google.com>

Sorry for the late reply as I'm on vacations currently.

Patch looks good to me, but it looks like it got whitespace
corrupted by your email client. Please submit this against
'net' in subject line. Otherwise when this is fixed, feel
free to add my ack:

Acked-by: Daniel Borkmann <dborkman@redhat.com>

Thanks, Brendan!

> ---
>   tools/net/bpf_dbg.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/tools/net/bpf_dbg.c b/tools/net/bpf_dbg.c
> index 65dc757..5e54848 100644
> --- a/tools/net/bpf_dbg.c
> +++ b/tools/net/bpf_dbg.c
> @@ -823,7 +823,7 @@ do_div:
>                  r->A &= r->X;
>                  break;
>          case BPF_ALU_AND | BPF_K:
> -               r->A &= r->X;
> +               r->A &= K;
>                  break;
>          case BPF_ALU_OR | BPF_X:
>                  r->A |= r->X;
>
