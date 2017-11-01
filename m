From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] selftests/bpf: remove useless bpf_trace_printk
Date: Wed, 01 Nov 2017 12:06:59 +0900 (KST)
Message-ID: <20171101.120659.465812628175456432.davem@davemloft.net>
References: <20171029001713.3552314-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, john.fastabend@gmail.com,
        netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44596 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752711AbdKADHE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 23:07:04 -0400
In-Reply-To: <20171029001713.3552314-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Sat, 28 Oct 2017 17:17:13 -0700

> sockmap test is using two programs that use bpf_trace_printk()
> which prints into trace_pipe, but nothing is reading it.
> Remove it.
> 
> Fixes: 6f6d33f3b3d0 ("bpf: selftests add sockmap tests")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks.
