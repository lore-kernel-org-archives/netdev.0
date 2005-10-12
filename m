From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] br: fix race on bridge del if
Date: Wed, 12 Oct 2005 15:10:14 -0700 (PDT)
Message-ID: <20051012.151014.12946945.davem@davemloft.net>
References: <20050818214036.GH10593@us.ibm.com>
	<20051011133328.26db65d7@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ryanh@us.ibm.com, netdev@oss.sgi.com, chrisw@osdl.org, greg@kroah.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20051011133328.26db65d7@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 11 Oct 2005 13:33:28 -0700

> This fixes the RCU race on bridge delete interface.  Basically,
> the network device has to be detached from the bridge in the first
> step (pre-RCU), rather than later. At that point, no more bridge traffic
> will come in, and the other code will not think that network device
> is part of a bridge.
> 
> This should also fix the XEN test problems. If there is another
> 2.6.13-stable, add it as well.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
