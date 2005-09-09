From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] 3c59x: read current link status from phy
Date: Thu, 08 Sep 2005 20:01:31 -0400
Message-ID: <4320D0DB.3040405@pobox.com>
References: <200509080125.j881PcL9015847@hera.kernel.org>	<431F9899.4060602@pobox.com>	<Pine.LNX.4.63.0509081351160.21354@dingo.iwr.uni-heidelberg.de>	<1126184700.4805.32.camel@tsc-6.cph.tpack.net>	<Pine.LNX.4.63.0509081521140.21354@dingo.iwr.uni-heidelberg.de>	<1126190554.4805.68.camel@tsc-6.cph.tpack.net>	<Pine.LNX.4.63.0509081713500.22954@dingo.iwr.uni-heidelberg.de>	<4320BD96.3060307@tpack.net> <20050908154114.69307f92.akpm@osdl.org> <4320C555.4020800@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Bogdan.Costescu@iwr.uni-heidelberg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965090AbVIIABq@vger.kernel.org>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <4320C555.4020800@tpack.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tommy Christensen wrote:
> Andrew Morton wrote:
> 
>> Should we also decrease the polling interval?  Perhaps only when the 
>> cable
>> is unplugged?
> 
> 
> Sounds like a plan. 60 seconds certainly strikes me as being very slow.
> OTOH, I'm not aware of the reasoning behind this choice in the first place.
> It might make sense for some odd setups.
> 
> Since I don't even have any HW to play around with, I think I'll step
> down for now.

The standard for Becker drivers is 5 seconds if link is down, and 60 
seconds if link is up, IIRC.

	Jeff
