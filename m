From: Greg KH <greg@kroah.com>
Subject: Re: [PATCHv8] net: Add batman-adv meshing protocol
Date: Thu, 16 Dec 2010 14:21:11 -0800
Message-ID: <20101216222111.GA13395@kroah.com>
References: <1292275168-19882-1-git-send-email-sven@narfation.org>
 <20101216.140153.232733922.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sven@narfation.org, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:40419 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756270Ab0LPWWU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Dec 2010 17:22:20 -0500
Content-Disposition: inline
In-Reply-To: <20101216.140153.232733922.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 02:01:53PM -0800, David Miller wrote:
> From: Sven Eckelmann <sven@narfation.org>
> Date: Mon, 13 Dec 2010 22:19:28 +0100
> 
> > B.A.T.M.A.N. (better approach to mobile ad-hoc networking) is a routing
> > protocol for multi-hop ad-hoc mesh networks. The networks may be wired or
> > wireless. See http://www.open-mesh.org/ for more information and user space
> > tools.
> > 
> > Signed-off-by: Sven Eckelmann <sven@narfation.org>
> 
> Applied, thanks Sven.
> 
> How do you want to take care of the copy that still lives under
> staging?
> 
> Greg, any preferences on your end?
> 
> I'm more than happy to do the removal from my net-next-2.6 tree
> since the bonafide copy of net/batman-adv is now there.

That might conflict with the patches that I have added to my tree for
merging in the .38 timeframe for the batman code.  How about I just drop
the whole drivers/staging/batman/ directory in my tree and then we don't
have any merge issues?

thanks,

greg k-h
