From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH 5/9] bpf: more SK_SKB selftests
Date: Mon, 28 Aug 2017 10:38:33 -0700
Message-ID: <20170828173831.n56hfv7bdiowlgfy@ast-mbp>
References: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
 <20170828141124.14143.92130.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, daniel@iogearbox.net, davem@davemloft.net,
        netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34416 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751271AbdH1Rif (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 13:38:35 -0400
Received: by mail-pg0-f66.google.com with SMTP id 63so847567pgc.1
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 10:38:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170828141124.14143.92130.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 07:11:24AM -0700, John Fastabend wrote:
> Tests packet read/writes and additional skb fields.
> 
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>

>  	{
> +		"invalid access of tc_classid for SK_SKB",
> +		.insns = {
> +			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
> +				    offsetof(struct __sk_buff, tc_classid)),
> +			BPF_EXIT_INSN(),
> +		},
> +		.result = REJECT,
> +		.prog_type = BPF_PROG_TYPE_SK_SKB,
> +		.errstr = "invalid bpf_context access",

it shouldn't be readable eight, right?
