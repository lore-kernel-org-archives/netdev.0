From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: Fix out-of-bound access on interpreters[]
Date: Thu, 29 Jun 2017 15:37:32 -0400 (EDT)
Message-ID: <20170629.153732.1036582619430791632.davem@davemloft.net>
References: <20170628174124.1545332-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@fb.com,
        kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45044 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751776AbdF2The (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 15:37:34 -0400
In-Reply-To: <20170628174124.1545332-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Wed, 28 Jun 2017 10:41:24 -0700

> The index is off-by-one when fp->aux->stack_depth
> has already been rounded up to 32.  In particular,
> if stack_depth is 512, the index will be 16.
> 
> The fix is to round_up and then takes -1 instead of round_down.
 ...
> Fixes: b870aa901f4b ("bpf: use different interpreter depending on required stack size")
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Acked-by: Alexei Starovoitov <ast@fb.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Martin.
