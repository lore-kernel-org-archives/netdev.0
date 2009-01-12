From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
 2.6.27
Date: Mon, 12 Jan 2009 06:30:08 +0100
Message-ID: <496AD560.4060009@trash.net>
References: <e7c4531f0901081558n429f7275w717774dbe9ccd895@mail.gmail.com> <20090109031408.GB11336@gondor.apana.org.au> <20090109115515.GA12486@gondor.apana.org.au> <20090109120455.GB12486@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Dykstra <john.dykstra1@gmail.com>,
	=?ISO-8859-15?Q?Ilpo_J=E4rv?= =?ISO-8859-15?Q?inen?=
	<ilpo.jarvinen@helsinki.fi>, Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Speedster <speedster@haveacry.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55850 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbZALFaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 00:30:24 -0500
In-Reply-To: <20090109120455.GB12486@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> bridge: Disable PPPOE/VLAN processing by default
> 
> The PPPOE/VLAN processing code in the bridge netfilter is broken
> by design.  The VLAN tag and the PPPOE session ID are an integral
> part of the packet flow information, yet they're completely
> ignored by the bridge netfilter.  This is potentially a security
> hole as it treats all VLANs and PPPOE sessions as the same.
> 
> What's more, it's actually broken for PPPOE as the bridge netfilter
> tries to trim the packets to the IP length without adjusting the
> PPPOE header (and adjusting the PPPOE header isn't much better
> since the PPPOE peer may require the padding to be present).
> 
> Therefore we should disable this by default.
> 
> It does mean that people relying on this feature may lose networking
> depending on how their bridge netfilter rules are configured.
> However, IMHO the problems this code causes are serious enough to
> warrant this.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

A good reason to disable this crap :)

Applied, thanks.
