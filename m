From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Linux support for 802.3af?
Date: Sat, 13 Mar 2010 00:43:05 +0000
Message-ID: <1268440985.7439.23.camel@localhost>
References: <4B9AD5CA.7000303@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:53314 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935115Ab0CMAnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Mar 2010 19:43:12 -0500
In-Reply-To: <4B9AD5CA.7000303@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-03-12 at 17:01 -0700, Philip A. Prindeville wrote:
> I was looking at this Marvell-based 4-port PCI card with PoE and
> thinking it would be handy for powering cameras and ip-phones, but don't
> remember seeing any kernel support for 802.3af...
> 
> http://www.korenix.com/jetcard-PoE_Universal_PCI_Card-2215-overview.htm
> 
> There's no support for 802.3af, right?

The standard MDIO ioctls can be used to access registers 11 and 12 on
PHYs with integrated PSE functionality.  There is no way of indicating
whether a PHY has such functionality, but a flag for this could be added
to the mdio_support field of struct ethtool_cmd.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

