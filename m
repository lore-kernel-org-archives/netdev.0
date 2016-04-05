From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 1/4] lib/test_bpf: Fix JMP_JSET tests
Date: Tue, 05 Apr 2016 21:32:00 +0200
Message-ID: <570412B0.9000203@iogearbox.net>
References: <5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>,
	Michael Holzheu <holzheu@linux.vnet.ibm.com>
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35201 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933351AbcDETcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 15:32:11 -0400
In-Reply-To: <5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/05/2016 12:02 PM, Naveen N. Rao wrote:
> JMP_JSET tests incorrectly used BPF_JNE. Fix the same.
>
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Paul Mackerras <paulus@samba.org>
> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

> ---
>   lib/test_bpf.c | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/lib/test_bpf.c b/lib/test_bpf.c
> index 27a7a26..e76fa4d 100644
> --- a/lib/test_bpf.c
> +++ b/lib/test_bpf.c
> @@ -4303,7 +4303,7 @@ static struct bpf_test tests[] = {
>   		.u.insns_int = {
>   			BPF_ALU32_IMM(BPF_MOV, R0, 0),
>   			BPF_LD_IMM64(R1, 3),
> -			BPF_JMP_IMM(BPF_JNE, R1, 2, 1),
> +			BPF_JMP_IMM(BPF_JSET, R1, 2, 1),
>   			BPF_EXIT_INSN(),
>   			BPF_ALU32_IMM(BPF_MOV, R0, 1),
>   			BPF_EXIT_INSN(),
> @@ -4317,7 +4317,7 @@ static struct bpf_test tests[] = {
>   		.u.insns_int = {
>   			BPF_ALU32_IMM(BPF_MOV, R0, 0),
>   			BPF_LD_IMM64(R1, 3),
> -			BPF_JMP_IMM(BPF_JNE, R1, 0xffffffff, 1),
> +			BPF_JMP_IMM(BPF_JSET, R1, 0xffffffff, 1),
>   			BPF_EXIT_INSN(),
>   			BPF_ALU32_IMM(BPF_MOV, R0, 1),
>   			BPF_EXIT_INSN(),
> @@ -4474,7 +4474,7 @@ static struct bpf_test tests[] = {
>   			BPF_ALU32_IMM(BPF_MOV, R0, 0),
>   			BPF_LD_IMM64(R1, 3),
>   			BPF_LD_IMM64(R2, 2),
> -			BPF_JMP_REG(BPF_JNE, R1, R2, 1),
> +			BPF_JMP_REG(BPF_JSET, R1, R2, 1),
>   			BPF_EXIT_INSN(),
>   			BPF_ALU32_IMM(BPF_MOV, R0, 1),
>   			BPF_EXIT_INSN(),
> @@ -4489,7 +4489,7 @@ static struct bpf_test tests[] = {
>   			BPF_ALU32_IMM(BPF_MOV, R0, 0),
>   			BPF_LD_IMM64(R1, 3),
>   			BPF_LD_IMM64(R2, 0xffffffff),
> -			BPF_JMP_REG(BPF_JNE, R1, R2, 1),
> +			BPF_JMP_REG(BPF_JSET, R1, R2, 1),
>   			BPF_EXIT_INSN(),
>   			BPF_ALU32_IMM(BPF_MOV, R0, 1),
>   			BPF_EXIT_INSN(),
>
