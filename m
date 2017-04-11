From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] bpf: pass sk to helper functions
Date: Tue, 11 Apr 2017 14:54:46 -0400 (EDT)
Message-ID: <20170411.145446.1300958521081310466.davem@davemloft.net>
References: <20170411180808.109636-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        fengc@google.com, lorenzo@google.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35176 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752224AbdDKSys (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 14:54:48 -0400
In-Reply-To: <20170411180808.109636-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Tue, 11 Apr 2017 14:08:08 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> BPF helper functions access socket fields through skb->sk. This is not
> set in ingress cgroup and socket filters. The association is only made
> in skb_set_owner_r once the filter has accepted the packet. Sk is
> available as socket lookup has taken place.
> 
> Temporarily set skb->sk to sk in these cases.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thank you.
