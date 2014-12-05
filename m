From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/3] netdev: introduce new NETIF_F_HW_SWITCH_OFFLOAD
 feature flag for switch device offloads
Date: Fri, 5 Dec 2014 22:43:20 +0000
Message-ID: <20141205224320.GA22992@casper.infradead.org>
References: <1417746401-8140-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34577 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbaLEWn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 17:43:26 -0500
Content-Disposition: inline
In-Reply-To: <1417746401-8140-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/14 at 06:26pm, roopa@cumulusnetworks.com wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This is a generic high level feature flag for all switch asic features today.
> 
> switch drivers set this flag on switch ports. Logical devices like
> bridge, bonds, vxlans can inherit this flag from their slaves/ports.
> 
> I had to use SWITCH in the name to avoid ambiguity with other feature
> flags. But, since i have been harping about not calling it 'switch',
> I am welcome to any suggestions :)
> 
> An alternative to using a feature flag is to use a IFF_HW_OFFLOAD
> in net_device_flags.

What does this flag indicate specifically? What driver would
implement ndo_bridge_setlink() but not set this flag?

I think it should be clearly documented when this flag is to bet set.
