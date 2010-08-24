From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch net-next] net: increase the size of priv_flags and add
 IFF_OVS_DATAPATH
Date: Tue, 24 Aug 2010 13:53:05 +0900
Message-ID: <20100824045256.GA21033@verge.net.au>
References: <20100824022637.GA11820@verge.net.au>
 <20100823.204408.35817944.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:35539 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840Ab0HXExK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 00:53:10 -0400
Content-Disposition: inline
In-Reply-To: <20100823.204408.35817944.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 23, 2010 at 08:44:08PM -0700, David Miller wrote:
> From: Simon Horman <horms@verge.net.au>
> Date: Tue, 24 Aug 2010 11:26:41 +0900
> 
> > IFF_OVS_DATAPATH is a place-holder for the Open vSwitch datapath
> > which I am preparing to submit for merging.
> > 
> > As all 16 bits of priv_flags are already assigned flags, also increase
> > the size of priv_flags to 32 bits.
> > 
> > Unfortunately, by my calculations this increases the size of
> > struct net_device by 4 bytes on 32bit architectures and
> > 8 bytes on 64 bit architectures. I couldn't see an obvious
> > way to avoid that.
> > 
> > Cc: Jesse Gross <jesse@nicira.com>
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> I can't think of a better way out of this, so applied for now.
> 
> Maybe somehow some of those bonding specific flags can get put
> down into the bonding private structure.  However, that might
> not be possible if the sole reason those live in ->priv_flags
> is to allow tests of the flags outside of the bonding code.

Thanks.

It seems to me that there is ample scope to do something.
But nothing seems obviously correct.

