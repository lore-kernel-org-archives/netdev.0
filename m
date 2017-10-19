From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] Fix for BPF devmap percpu allocation splat
Date: Thu, 19 Oct 2017 13:14:46 +0100 (WEST)
Message-ID: <20171019.131446.1318832753285984633.davem@davemloft.net>
References: <cover.1508251210.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tj@kernel.org, ast@kernel.org, john.fastabend@gmail.com,
        mark.rutland@arm.com, richard@nod.at, sp3485@columbia.edu,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48804 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752962AbdJSMPE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 08:15:04 -0400
In-Reply-To: <cover.1508251210.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 17 Oct 2017 16:55:51 +0200

> The set fixes a splat in devmap percpu allocation when we alloc
> the flush bitmap. Patch 1 is a prerequisite for the fix in patch 2,
> patch 1 is rather small, so if this could be routed via -net, for
> example, with Tejun's Ack that would be good. Patch 3 gets rid of
> remaining PCPU_MIN_UNIT_SIZE checks, which are percpu allocator
> internals and should not be used.

Series applied.
