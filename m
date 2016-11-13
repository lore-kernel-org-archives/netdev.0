From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: __skb_flow_dissect() must cap its return value
Date: Sat, 12 Nov 2016 23:42:32 -0500 (EST)
Message-ID: <20161112.234232.1152946645540246281.davem@davemloft.net>
References: <1477438271.7065.157.camel@edumazet-glaptop3.roam.corp.google.com>
        <1478718427.16809.7.camel@edumazet-glaptop3.roam.corp.google.com>
        <1478736286.16809.17.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yibyang@cisco.com, tom@herbertland.com, jojvargh@cisco.com,
        alexander.h.duyck@intel.com, ast@kernel.org, willemb@google.com,
        netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60044 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932412AbcKMEmi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2016 23:42:38 -0500
In-Reply-To: <1478736286.16809.17.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 09 Nov 2016 16:04:46 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> After Tom patch, thoff field could point past the end of the buffer,
> this could fool some callers.
> 
> If an skb was provided, skb->len should be the upper limit.
> If not, hlen is supposed to be the upper limit.
> 
> Fixes: a6e544b0a88b ("flow_dissector: Jump to exit code in __skb_flow_dissect")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Yibin Yang <yibyang@cisco.com
> Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Acked-by: Willem de Bruijn <willemb@google.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied and queued up for -stable, thanks Eric.
