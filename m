From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] bpf: reduce verifier memory consumption
Date: Wed, 01 Nov 2017 11:41:38 +0900 (KST)
Message-ID: <20171101.114138.794863370939731562.davem@davemloft.net>
References: <20171101011605.4166099-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ecree@solarflare.com,
        jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44138 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932210AbdKACll (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 22:41:41 -0400
In-Reply-To: <20171101011605.4166099-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Tue, 31 Oct 2017 18:16:05 -0700

> the verifier got progressively smarter over time and size of its internal
> state grew as well. Time to reduce the memory consumption.
> 
> Before:
> sizeof(struct bpf_verifier_state) = 6520
> After:
> sizeof(struct bpf_verifier_state) = 896
> 
> It's done by observing that majority of BPF programs use little to
> no stack whereas verifier kept all of 512 stack slots ready always.
> Instead dynamically reallocate struct verifier state when stack
> access is detected.
> Runtime difference before vs after is within a noise.
> The number of processed instructions stays the same.
> 
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Alexei.
