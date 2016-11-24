From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] samples/bpf: fix sockex2 example
Date: Thu, 24 Nov 2016 16:05:04 -0500 (EST)
Message-ID: <20161124.160504.2054406480214878235.davem@davemloft.net>
References: <1479862329-2361912-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41716 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966179AbcKXVFL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 16:05:11 -0500
In-Reply-To: <1479862329-2361912-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Tue, 22 Nov 2016 16:52:08 -0800

> since llvm commit "Do not expand UNDEF SDNode during insn selection lowering"
> llvm will generate code that uses uninitialized registers for cases
> where C code is actually uses uninitialized data.
> So this sockex2 example is technically broken.
> Fix it by initializing on the stack variable fully.
> Also increase verifier buffer limit, since verifier output
> may not fit in 64k for this sockex2 code depending on llvm version.
> 
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Applied.
