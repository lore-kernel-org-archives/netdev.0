From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH 1/9] bpf: convert sockmap field attach_bpf_fd2
 to type
Date: Mon, 28 Aug 2017 10:22:04 -0700
Message-ID: <20170828172202.mhwqfssg6xgssi52@ast-mbp>
References: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
 <20170828141004.14143.19285.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, daniel@iogearbox.net, davem@davemloft.net,
        netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36836 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdH1RWI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 13:22:08 -0400
Received: by mail-pg0-f50.google.com with SMTP id r133so3238038pgr.3
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 10:22:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170828141004.14143.19285.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 07:10:04AM -0700, John Fastabend wrote:
> In the initial sockmap API we provided strparser and verdict programs
> using a single attach command by extending the attach API with a the
> attach_bpf_fd2 field.
> 
> However, if we add other programs in the future we will be adding a
> field for every new possible type, attach_bpf_fd(3,4,..). This
> seems a bit clumsy for an API. So lets push the programs using two
> new type fields.
> 
>    BPF_SK_SKB_STREAM_PARSER
>    BPF_SK_SKB_STREAM_VERDICT
> 
> This has the advantage of having a readable name and can easily be
> extended in the future.
> 
> Updates to samples and sockmap included here also generalize tests
> slightly to support upcoming patch for multiple map support.
> 
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>
> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
> Suggested-by: Alexei Starovoitov <ast@kernel.org>

lgtm
Acked-by: Alexei Starovoitov <ast@kernel.org>
