From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: add bpf_get_hash_recalc helper
Date: Mon, 04 Jul 2016 16:08:56 -0700 (PDT)
Message-ID: <20160704.160856.1726060549877002377.davem@davemloft.net>
References: <6c3f3fd083314b49742d65c54e71e27804b26663.1467501451.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [184.105.139.130] ([184.105.139.130]:51178 "EHLO
	shards.monkeyblade.net" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753568AbcGDXI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 19:08:57 -0400
In-Reply-To: <6c3f3fd083314b49742d65c54e71e27804b26663.1467501451.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sun,  3 Jul 2016 01:28:47 +0200

> If skb_clear_hash() was invoked due to mangling of relevant headers and
> BPF program needs skb->hash later on, we can add a helper to trigger hash
> recalculation via bpf_get_hash_recalc().
> 
> The helper will return the newly retrieved hash directly, but later access
> can also be done via skb context again through skb->hash directly (inline)
> without needing to call the helper once more.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied.
