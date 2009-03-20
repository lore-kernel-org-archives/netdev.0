From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/3] dsa: add switch chip cascading support
Date: Fri, 20 Mar 2009 21:16:18 +0000
Message-ID: <1237583778.3217.4.camel@achroite>
References: <20090320195209.GW4738@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Gary Thomas <gary@mlbassoc.com>,
	Jesper Dangaard Brouer <hawk@diku.dk>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:35197 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752074AbZCTVQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 17:16:28 -0400
In-Reply-To: <20090320195209.GW4738@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-03-20 at 20:52 +0100, Lennert Buytenhek wrote:
[...]
> For the example topology above, the dsa platform data would look
> something like this:
> 
> 	static struct dsa_chip_data sw[2] = {
> 		{
> 			.mii_bus	= &foo,
> 			.sw_addr	= 1,
> 			.port_names[0]	= "p1",
> 			.port_names[1]	= "p2",
> 			.port_names[2]	= "p3",
> 			.port_names[3]	= "p4",
> 			.port_names[4]	= "p5",
> 			.port_names[5]	= "p6",
> 			.port_names[6]	= "p7",
> 			.port_names[7]	= "p8",
> 			.port_names[9]	= "dsa",
> 			.port_names[10]	= "cpu",
> 			.rtable		= (s8 []){ -1, 9, },
[...]

Is there supposed to be a gap in the numbering here?  The diagram above
seemed to number the ports 1-10 but I'm guessing the internal numbering
of those would be 0-9.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

