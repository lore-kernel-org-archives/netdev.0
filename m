From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ila: Fix tailroom allocation of lwtstate
Date: Thu, 20 Oct 2016 11:20:19 -0400 (EDT)
Message-ID: <20161020.112019.468220952101459876.davem@davemloft.net>
References: <d7e2292a2be9d142a05b7c528746820bac358065.1476911506.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42010 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965049AbcJTPUU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 11:20:20 -0400
In-Reply-To: <d7e2292a2be9d142a05b7c528746820bac358065.1476911506.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 19 Oct 2016 23:16:39 +0200

> Tailroom is supposed to be of length sizeof(struct ila_lwt) but
> sizeof(struct ila_params) is currently allocated.
> 
> This leads to the dst_cache and connected member of ila_lwt being
> referenced out of bounds.
> 
> struct ila_lwt {
> 	struct ila_params p;
> 	struct dst_cache dst_cache;
> 	u32 connected : 1;
> };
> 
> Fixes: 65d7ab8de582 ("net: Identifier Locator Addressing module")
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  -stable candidate

This patch only applies to net-next, so I've applied it there.

Please explain how I should handle 'net' and -stable.
