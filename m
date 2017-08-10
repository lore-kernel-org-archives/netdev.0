From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: core: fix compile error inside
 flow_dissector due to new dsa callback
Date: Thu, 10 Aug 2017 09:16:53 -0700 (PDT)
Message-ID: <20170810.091653.1966810110752157678.davem@davemloft.net>
References: <20170810080903.32231-1-john@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, edumazet@google.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: john@phrozen.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170810080903.32231-1-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Crispin <john@phrozen.org>
Date: Thu, 10 Aug 2017 10:09:03 +0200

> The following error was introduced by
> commit 43e665287f93 ("net-next: dsa: fix flow dissection")
> due to a missing #if guard
> 
> net/core/flow_dissector.c: In function '__skb_flow_dissect':
> net/core/flow_dissector.c:448:18: error: 'struct net_device' has no member named 'dsa_ptr'
> ops = skb->dev->dsa_ptr->tag_ops;
>                 ^
> make[3]: *** [net/core/flow_dissector.o] Error 1
> 
> Signed-off-by: John Crispin <john@phrozen.org>

Applied, thanks.
