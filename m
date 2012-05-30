From: Eldad Zack <eldad@fogrefinery.com>
Subject: Re: [PATCH] 8021q/vlan: process NETDEV_GOING_DOWN
Date: Wed, 30 May 2012 23:47:32 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1205302344200.8234@debianer>
References: <1338330635-27259-1-git-send-email-eldad@fogrefinery.com> <20120529.204040.644013889059321702.davem@davemloft.net> <alpine.DEB.2.02.1205302055140.1587@debianer> <20120530.162751.80640634568619332.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120530.162751.80640634568619332.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 30 May 2012, David Miller wrote:
> From: Eldad Zack <eldad@fogrefinery.com>
> Date: Wed, 30 May 2012 21:11:02 +0200 (CEST)
> 
> > In case a certain protocol needs to send a "dying gasp" packet, when you 
> > administrativly shutdown the port (which is also what happens when you 
> > restart the machine).
> 
> No in tree users have this requirement, therefore your patch is
> inappropriate.

You are right in that, that no in tree users have this requirement 
(yet), but in the same time it doesn't harm any existing code.

Don't you agree that it's the right order to do the notifications?
And if so, isn't that enough, considering that there are no side 
effects and it's a tiny change?

Eldad
