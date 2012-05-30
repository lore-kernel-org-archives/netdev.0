From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8021q/vlan: process NETDEV_GOING_DOWN
Date: Wed, 30 May 2012 17:50:20 -0400 (EDT)
Message-ID: <20120530.175020.1714406888633137662.davem@davemloft.net>
References: <alpine.DEB.2.02.1205302055140.1587@debianer>
	<20120530.162751.80640634568619332.davem@davemloft.net>
	<alpine.DEB.2.02.1205302344200.8234@debianer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eldad@fogrefinery.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1205302344200.8234@debianer>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eldad Zack <eldad@fogrefinery.com>
Date: Wed, 30 May 2012 23:47:32 +0200 (CEST)

> 
> On Wed, 30 May 2012, David Miller wrote:
>> From: Eldad Zack <eldad@fogrefinery.com>
>> Date: Wed, 30 May 2012 21:11:02 +0200 (CEST)
>> 
>> > In case a certain protocol needs to send a "dying gasp" packet, when you 
>> > administrativly shutdown the port (which is also what happens when you 
>> > restart the machine).
>> 
>> No in tree users have this requirement, therefore your patch is
>> inappropriate.
> 
> You are right in that, that no in tree users have this requirement 
> (yet), but in the same time it doesn't harm any existing code.
> 
> Don't you agree that it's the right order to do the notifications?

It's not an issue that matters upstream, so I simply do not care.

When you, or someone else, submits code that needs this facility
then we can talk about it.

Otherwise it's just a waste of our time.
