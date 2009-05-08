From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next-2.6] Network Drop Monitor: Fix
	skb_kill_datagram
Date: Thu, 7 May 2009 20:42:00 -0400
Message-ID: <20090508004200.GA15970@localhost.localdomain>
References: <1241731554.6567.25.camel@Maple> <20090507.145649.169552244.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.dykstra1@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42461 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764613AbZEHAmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 20:42:06 -0400
Content-Disposition: inline
In-Reply-To: <20090507.145649.169552244.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 07, 2009 at 02:56:49PM -0700, David Miller wrote:
> From: John Dykstra <john.dykstra1@gmail.com>
> Date: Thu, 07 May 2009 21:25:54 +0000
> 
> > Commit ead2ceb0ec9f85cff19c43b5cdb2f8a054484431 ("Network Drop Monitor:
> > Adding kfree_skb_clean for non-drops and modifying end-of-line points
> > for skbs") established new conventions for identifying dropped packets.
> > 
> > Align skb_kill_datagram() with these conventions so that packets that
> > get dropped just before the copy to userspace are properly tracked.
> > 
> > Signed-off-by: John Dykstra <john.dykstra1@gmail.com>
> 
> Neil, ACK?
> 

Yes, I think it looks good, thank you Jonh, Dave!

Acked-by: Neil Horman <nhorman@tuxdriver.com>

