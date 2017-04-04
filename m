From: Simon Horman <simon.horman@netronome.com>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 4 Apr 2017 10:48:35 -0400
Message-ID: <20170404144833.GC32295@vergenet.net>
References: <20170404111357.26975ab4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170404111357.26975ab4@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 04, 2017 at 11:13:57AM +1000, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in:
> 
>   net/core/flow_dissector.c
> 
> between commit:
> 
>   ac6a3722fed6 ("flow dissector: correct size of storage for ARP")
> 
> from the net tree and commit:
> 
>   9bf881ffc5c0 ("flow_dissector: Move ARP dissection into a separate function")
> 
> from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.

Thanks Stephen, the fix looks correct to me.
