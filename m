From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf, arm64: take advantage of stack_depth
 tracking
Date: Sun, 11 Jun 2017 18:18:53 -0400 (EDT)
Message-ID: <20170611.181853.19339299534970449.davem@davemloft.net>
References: <afc90487fc573886a44178c2428f3157312128d8.1497145004.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41028 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751886AbdFKWSz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 18:18:55 -0400
In-Reply-To: <afc90487fc573886a44178c2428f3157312128d8.1497145004.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sun, 11 Jun 2017 03:55:27 +0200

> Make use of recently implemented stack_depth tracking for arm64 JIT,
> so that stack usage can be reduced heavily for programs not using
> tail calls at least.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks Daniel.
