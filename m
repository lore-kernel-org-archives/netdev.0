From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Sun, 17 Apr 2016 18:38:51 -0700
Message-ID: <1460943531.10638.99.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160418113116.6f7f8740@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Craig Gallek <kraig@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20160418113116.6f7f8740@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-04-18 at 11:31 +1000, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in:
> 
>   net/ipv4/udp.c
> 
> between commit:
> 
>   d894ba18d4e4 ("soreuseport: fix ordering for mixed v4/v6 sockets")
> 
> from the net tree and commit:
> 
>   ca065d0cf80f ("udp: no longer use SLAB_DESTROY_BY_RCU")
> 
> from the net-next tree.
> 
> I tried to fixed it up (see below).  Unfortunately,
> hlist_add_tail_rcu() does not exist.  So instead I have reverted commit
> d894ba18d4e4 ("soreuseport: fix ordering for mixed v4/v6 sockets") for
> today.

Hi Stephen

Craig warned that this would happen indeed, and provided a net-next
patch, to help David with this conflict.

https://patchwork.ozlabs.org/patch/611093/

Thanks
