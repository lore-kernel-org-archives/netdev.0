From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
 2.6.27
Date: Mon, 12 Jan 2009 06:27:43 +0100
Message-ID: <496AD4CF.4070807@trash.net>
References: <e7c4531f0901081558n429f7275w717774dbe9ccd895@mail.gmail.com> <20090109031408.GB11336@gondor.apana.org.au> <20090109115515.GA12486@gondor.apana.org.au>
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
Received: from stinky.trash.net ([213.144.137.162]:55809 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbZALF2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 00:28:00 -0500
In-Reply-To: <20090109115515.GA12486@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> It turns out that even though we have sysctl's that's supposed
> to control pppoe/vlan processing, they don't actually work.

Which reminds me - I think we should change them to default to off,
they regulary break things for unsuspecting users. I'm not sure
though what the best way to warn people for a while would be,
feature-removal-schedule doesn't seem approriate.

> This patch should make them work.
> 
> bridge: Fix handling of non-IP packets in FORWARD/POST_ROUTING
> 
> Currently the bridge FORWARD/POST_ROUTING chains treats all
> non-IPv4 packets as IPv6.  This packet fixes that by returning
> NF_ACCEPT on non-IP packets instead, just as is done in PRE_ROUTING.

Applied, thanks.
