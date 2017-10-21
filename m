From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net 2/3] bpf: fix pattern matches for direct packet access
Date: Sat, 21 Oct 2017 09:39:49 -0700
Message-ID: <186b7772-3f78-1b68-86c2-960a825fbc46@gmail.com>
References: <cover.1508545543.git.daniel@iogearbox.net>
 <40e994d92bf40661a94e52de299d12fe5538f9c7.1508545543.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, john.r.fastabend@gmail.com,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:48956 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932196AbdJUQkH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 12:40:07 -0400
Received: by mail-pg0-f47.google.com with SMTP id v78so8791690pgb.5
        for <netdev@vger.kernel.org>; Sat, 21 Oct 2017 09:40:07 -0700 (PDT)
In-Reply-To: <40e994d92bf40661a94e52de299d12fe5538f9c7.1508545543.git.daniel@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2017 05:34 PM, Daniel Borkmann wrote:
> Alexander had a test program with direct packet access, where
> the access test was in the form of data + X > data_end. In an
> unrelated change to the program LLVM decided to swap the branches
> and emitted code for the test in form of data + X <= data_end.
> We hadn't seen these being generated previously, thus verifier
> would reject the program. Therefore, fix up the verifier to
> detect all test cases, so we don't run into such issues in the
> future.
> 
> Fixes: b4e432f1000a ("bpf: enable BPF_J{LT, LE, SLT, SLE} opcodes in verifier")
> Reported-by: Alexander Alemayhu <alexander@alemayhu.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> ---

Acked-by: John Fastabend <john.fastabend@gmail.com>
