From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [PATCH] via-rhine: do not abort due to invalid MAC address
Date: Wed, 2 Mar 2011 20:52:05 +0100
Message-ID: <20110302195205.GA15190@core.hellgate.ch>
References: <20110302163233.GA14491@core.hellgate.ch>
 <201103021901.39849.florian@openwrt.org>
 <4D6E883C.2000800@gmail.com>
 <20110302.113610.71137356.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mr.nuke.me@gmail.com, florian@openwrt.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail17.bluewin.ch ([195.186.18.64]:40155 "EHLO
	mail17.bluewin.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756670Ab1CBTwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 14:52:03 -0500
Content-Disposition: inline
In-Reply-To: <20110302.113610.71137356.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 02 Mar 2011 11:36:10 -0800, David Miller wrote:
> From: "Alex G." <mr.nuke.me@gmail.com>
> Date: Wed, 02 Mar 2011 20:11:08 +0200
> 
> > On 03/02/2011 08:01 PM, Florian Fainelli wrote:
> >> 
> >> Why not generate a valid random ethernet address using random_ether_addr() 
> >> instead?
> > 
> > That would confuse ifcfg-* scripts that specify HWETHER, and probably
> > users as well. It might even stump udev.
> 
> If the ethernet address reported by the card is garbage, every single
> ethernet driver that tried to handle this case uses a random ethernet
> address.
>
> There is no reason to choose a different strategy for this driver.

Fair enough. I did not know other drivers had already dealt with the same
problem. My bad. Alex, can you redo the patch accordingly?
