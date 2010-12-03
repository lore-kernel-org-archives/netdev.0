From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbe: fix link behavior for SFP+ when
 driver is brought down
Date: Fri, 03 Dec 2010 09:42:15 -0800 (PST)
Message-ID: <20101203.094215.229763630.davem@davemloft.net>
References: <20101203133151.21637.52883.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57422
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751168Ab0LCRls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 12:41:48 -0500
In-Reply-To: <20101203133151.21637.52883.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please number your patches so I know unambiguously in which order to
apply them.

The last patch didn't apply cleanly because ixgbe_types.h in your
tree has:

#define IXGBE_ERR_SFP_SETUP_NOT_COMPLETE        -30

but that does not exist in net-next-2.6  This doesn't exist in
net-2.6 either so it's something completely local to your trees.

I fixed all of this up and applied it all, but this sort of stuff
needs to be sorted out before I see the submission. :-)
