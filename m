From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 1/2] natsemi: Add support for using MII port with no PHY
Date: Tue, 20 Feb 2007 11:18:56 -0500
Message-ID: <45DB1F70.608@garzik.org>
References: <20070219201538.420238000@sirena.org.uk> <20070219201858.688614000@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tim Hockin <thockin@hockin.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: Mark Brown <broonie@sirena.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44512 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030195AbXBTQTA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 11:19:00 -0500
In-Reply-To: <20070219201858.688614000@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Brown wrote:
> This patch provides code paths which allow the natsemi driver to use the
> external MII port on the chip but ignore any PHYs that may be attached to it.
> The link state will be left as it was when the driver started and can be
> configured via ethtool.  Any PHYs that are present can be accessed via the MII
> ioctl()s.
> 
> This is useful for systems where the device is connected without a PHY
> or where either information or actions outside the scope of the driver
> are required in order to use the PHYs.
> 
> Signed-Off-By: Mark Brown <broonie@sirena.org.uk>
> 
> ---
> 
> This revision of the patch fixes some issues brought up during review.
> 
> Previous versions of this patch exposed the new functionality as a module
> option.  This has been removed.  Any hardware that needs this should be
> identifiable by a quirk since it unlikely to behave correctly with an
> unmodified driver.

applied 1-2


