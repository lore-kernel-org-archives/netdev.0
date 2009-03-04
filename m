From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Patch 1/5] Network Drop Monitor: Add netlink protocol
	identifer
Date: Wed, 4 Mar 2009 10:39:51 -0500
Message-ID: <20090304153951.GC6139@hmsreliant.think-freely.org>
References: <20090303170014.GB1480@hmsreliant.think-freely.org> <20090303182006.GB29236@ioremap.net> <20090303.141749.210780391.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zbr@ioremap.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50668 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753654AbZCDPkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 10:40:04 -0500
Content-Disposition: inline
In-Reply-To: <20090303.141749.210780391.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 03, 2009 at 02:17:49PM -0800, David Miller wrote:
> From: Evgeniy Polyakov <zbr@ioremap.net>
> Date: Tue, 3 Mar 2009 21:20:06 +0300
> 
> > Why do you want to use own family instead of using existing netlink
> > helpers like connector or genetlink?
> 
> Yes, indeed, use genetlink for this.
> 
> We don't add new core netlink protocols any more with it's
> fixed address space of link types.
> 

very well, I'll make the change, and repost in a few days when I have it all
tested.
Neil

