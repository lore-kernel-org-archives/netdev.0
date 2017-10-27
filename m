From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net PATCH 2/2] bpf: rename sk_actions to align with bpf
 infrastructure
Date: Fri, 27 Oct 2017 12:44:22 -0700
Message-ID: <20171027194421.g3gceyjxlybxctan@ast-mbp>
References: <20171027163830.28498.82997.stgit@john-Precision-Tower-5810>
 <20171027164553.28498.47472.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, edumazet@google.com,
        daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:49586 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932356AbdJ0ToZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 15:44:25 -0400
Received: by mail-pg0-f68.google.com with SMTP id g6so6025022pgn.6
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 12:44:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171027164553.28498.47472.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 27, 2017 at 09:45:53AM -0700, John Fastabend wrote:
> Recent additions to support multiple programs in cgroups impose
> a strict requirement, "all yes is yes, any no is no". To enforce
> this the infrastructure requires the 'no' return code, SK_DROP in
> this case, to be 0.
> 
> To apply these rules to SK_SKB program types the sk_actions return
> codes need to be adjusted.
> 
> This fix adds SK_PASS and makes 'SK_DROP = 0'. Finally, remove
> SK_ABORTED to remove any chance that the API may allow aborted
> program flows to be passed up the stack. This would be incorrect
> behavior and allow programs to break existing policies.
> 
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
