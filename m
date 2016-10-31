From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net] mlxsw: spectrum: Fix incorrect reuse of MID entries
Date: Mon, 31 Oct 2016 22:36:16 +0200
Message-ID: <20161031203616.3yuvu2l4k3xf6yb7@splinter>
References: <1477818562-30185-1-git-send-email-jiri@resnulli.us>
 <20161031.153606.989406936490082438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, netdev@vger.kernel.org, eladr@mellanox.com,
        idosch@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:50159 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S946369AbcJaUgo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:36:44 -0400
Content-Disposition: inline
In-Reply-To: <20161031.153606.989406936490082438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Oct 31, 2016 at 03:36:06PM -0400, David Miller wrote:
> From: Jiri Pirko <jiri@resnulli.us>
> Date: Sun, 30 Oct 2016 10:09:22 +0100
> 
> > From: Ido Schimmel <idosch@mellanox.com>
> > 
> > In the device, a MID entry represents a group of local ports, which can
> > later be bound to a MDB entry.
> > 
> > The lookup of an existing MID entry is currently done using the provided
> > MC MAC address and VID, from the Linux bridge. However, this can result
> > in an incorrect reuse of the same MID index in different VLAN-unaware
> > bridges (same IP MC group and VID 0).
> > 
> > Fix this by performing the lookup based on FID instead of VID, which is
> > unique across different bridges.
> > 
> > Fixes: 3a49b4fde2a1 ("mlxsw: Adding layer 2 multicast support")
> > Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> > Acked-by: Elad Raz <eladr@mellanox.com>
> > Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> 
> Applied, should I queue this up for -stable?

I don't think it's necessary, but thanks for asking! We recently picked
up the habit of noting what we would like to see in -stable.
