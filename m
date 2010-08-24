From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: increase the size of priv_flags and add
 IFF_OVS_DATAPATH
Date: Mon, 23 Aug 2010 20:44:08 -0700 (PDT)
Message-ID: <20100823.204408.35817944.davem@davemloft.net>
References: <20100824022637.GA11820@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54122
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751826Ab0HXDnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 23:43:51 -0400
In-Reply-To: <20100824022637.GA11820@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Tue, 24 Aug 2010 11:26:41 +0900

> IFF_OVS_DATAPATH is a place-holder for the Open vSwitch datapath
> which I am preparing to submit for merging.
> 
> As all 16 bits of priv_flags are already assigned flags, also increase
> the size of priv_flags to 32 bits.
> 
> Unfortunately, by my calculations this increases the size of
> struct net_device by 4 bytes on 32bit architectures and
> 8 bytes on 64 bit architectures. I couldn't see an obvious
> way to avoid that.
> 
> Cc: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>

I can't think of a better way out of this, so applied for now.

Maybe somehow some of those bonding specific flags can get put
down into the bonding private structure.  However, that might
not be possible if the sole reason those live in ->priv_flags
is to allow tests of the flags outside of the bonding code.
