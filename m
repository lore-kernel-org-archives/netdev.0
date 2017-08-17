From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: fix liveness propagation to parent in
 spilled stack slots
Date: Thu, 17 Aug 2017 10:16:11 -0700 (PDT)
Message-ID: <20170817.101611.23983207839678338.davem@davemloft.net>
References: <058693b94f456324fd1a3d5946fa486e3a09ca06.1502974643.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, ast@fb.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59940 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753742AbdHQRQM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 13:16:12 -0400
In-Reply-To: <058693b94f456324fd1a3d5946fa486e3a09ca06.1502974643.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 17 Aug 2017 14:59:40 +0200

> Using parent->regs[] when propagating REG_LIVE_READ for spilled regs
> doesn't work since parent->regs[] denote the set of normal registers
> but not spilled ones. Propagate to the correct regs.
> 
> Fixes: dc503a8ad984 ("bpf/verifier: track liveness for pruning")
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Edward Cree <ecree@solarflare.com>

Applied.
