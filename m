From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net] net: core: Correctly iterate over lower adjacency
 list
Date: Wed, 19 Oct 2016 18:36:27 +0300
Message-ID: <20161019153627.GA28249@splinter>
References: <1476885428-5189-1-git-send-email-idosch@idosch.org>
 <20161019.103829.1873231752009765175.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        dsa@cumulusnetworks.com, idosch@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:36805 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S942983AbcJSPga (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 11:36:30 -0400
Content-Disposition: inline
In-Reply-To: <20161019.103829.1873231752009765175.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Wed, Oct 19, 2016 at 10:38:29AM -0400, David Miller wrote:
> From: idosch@idosch.org
> Date: Wed, 19 Oct 2016 16:57:08 +0300
> 
> > From: Ido Schimmel <idosch@mellanox.com>
> > 
> > Tamir reported the following trace when processing ARP requests received
> > via a vlan device on top of a VLAN-aware bridge:
>  ...
> > The problem is that netdev_all_lower_get_next_rcu() never advances the
> > iterator, thereby causing the loop over the lower adjacency list to run
> > forever.
> > 
> > Fix this by advancing the iterator and avoid the infinite loop.
> > 
> > Fixes: 7ce856aaaf13 ("mlxsw: spectrum: Add couple of lower device helper functions")
> > Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> > Reported-by: Tamir Winetroub <tamirw@mellanox.com>
> > Reviewed-by: Jiri Pirko <jiri@mellanox.com>
> 
> Applied.

Below the patch I noted "Please consider queueing this for 4.8.y", but
you didn't reply and I don't see it here:
https://patchwork.ozlabs.org/bundle/davem/stable/?state=*

So I'm not sure if this was rejected or you just missed my note.

Thanks
