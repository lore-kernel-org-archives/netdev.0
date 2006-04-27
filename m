From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 3/9] natsemi: Add support for using MII port with no PHY
Date: Thu, 27 Apr 2006 05:54:58 -0400
Message-ID: <445094F2.1060807@garzik.org>
References: <200604270932.k3R9W5lK025315@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, broonie@sirena.org.uk, jgarzik@pobox.com,
	thockin@hockin.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:6053 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965065AbWD0JzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 05:55:03 -0400
To: akpm@osdl.org
In-Reply-To: <200604270932.k3R9W5lK025315@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Mark Brown <broonie@sirena.org.uk>
> 
> Provide a module option which configures the natsemi driver to use the
> external MII port on the chip but ignore any PHYs that may be attached to it. 
> The link state will be left as it was when the driver started and can be
> configured via ethtool.  Any PHYs that are present can be accessed via the MII
> ioctl()s.
> 
> This is useful for systems where the device is connected without a PHY or
> where either information or actions outside the scope of the driver are
> required in order to use the PHYs.
> 
> Signed-off-by: Mark Brown <broonie@sirena.org.uk>
> Cc: Tim Hockin <thockin@hockin.org>
> Cc: Jeff Garzik <jgarzik@pobox.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

NAK.

The proper way to do this is via the force_media boolean flag found in 
several net drivers.

In general I agree with the motivation to do something like this...

	Jeff



