From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] ethtool: Flags for fibre speed switching
Date: Tue, 22 Jun 2010 10:17:44 -0700 (PDT)
Message-ID: <20100622.101744.70185793.davem@davemloft.net>
References: <1276543562.2074.41.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@redhat.com,
	linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42641
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755423Ab0FVRRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 13:17:32 -0400
In-Reply-To: <1276543562.2074.41.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 14 Jun 2010 20:26:02 +0100

> ethtool.h currently defines only SUPPORTED_FIBRE to cover all fibre
> modes.  However, SFP+ slots support both 1G and 10G fibre modules and
> some modules are dual-speed.  Some drivers use the BASE-T flags for SFP+
> modules of all media types, but this is strictly incorrect and can be
> confusing as there are real BASE-T modules for SFP+.  There should be
> distinct flags for fibre modes.  However I'm not sure whether it's worth
> defining flags for each fibre mode (there are quite a few) or only for
> each speed.
> 
> Similarly there is only ADVERTISED_FIBRE to cover all fibre modes.
> Although there is no AN protocol for fibre, an SFP+ NIC effectively
> autonegotiates its speed with the module.  By default, an SFP+ NIC will
> accept both 1G and 10G modules and switch speed automatically.  With a
> dual-speed module, the NIC driver can allow forcing the speed through
> ethtool, but unless it maintains some hidden state it must reset the
> speed whenever the module is hotplugged (perhaps accidentally).  So it
> should be possible for the administrator to control speed selection in a
> sticky way through the advertising mask.

I'm fine with this, feel free to make a formal submission for
net-next-2.6
