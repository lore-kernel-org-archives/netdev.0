From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] samples/bpf: fix include path
Date: Wed, 30 Nov 2016 12:42:45 -0500 (EST)
Message-ID: <20161130.124245.598666621159226107.davem@davemloft.net>
References: <1480399642-2475887-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37368 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756843AbcK3Rmr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 12:42:47 -0500
In-Reply-To: <1480399642-2475887-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Mon, 28 Nov 2016 22:07:22 -0800

> Fix the following build error:
> HOSTCC  samples/bpf/test_lru_dist.o
> ../samples/bpf/test_lru_dist.c:25:22: fatal error: bpf_util.h: No such file or directory
> 
> This is due to objtree != srctree.
> Use srctree, since that's where bpf_util.h is located.
> 
> Fixes: e00c7b216f34 ("bpf: fix multiple issues in selftest suite and samples")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks.
