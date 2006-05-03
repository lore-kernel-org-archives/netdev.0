From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 3/9] natsemi: Add support for using MII port with no PHY
Date: Wed, 03 May 2006 07:07:12 -0400
Message-ID: <44588EE0.5070307@garzik.org>
References: <200604270932.k3R9W5lK025315@shell0.pdx.osdl.net> <445094F2.1060807@garzik.org> <20060428130139.GA20068@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:27792 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965145AbWECLHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 07:07:15 -0400
To: Jeff Garzik <jeff@garzik.org>, akpm@osdl.org,
	netdev@vger.kernel.org, jgarzik@pobox.com, thockin@hockin.org
In-Reply-To: <20060428130139.GA20068@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Brown wrote:
> On Thu, Apr 27, 2006 at 05:54:58AM -0400, Jeff Garzik wrote:
> 
>>> Provide a module option which configures the natsemi driver to use the
>>> external MII port on the chip but ignore any PHYs that may be attached to 
>>> it. The link state will be left as it was when the driver started and can 
> 
>> The proper way to do this is via the force_media boolean flag found in 
>> several net drivers.
> 
> I've had a look at several of the net drivers that implement this option
> (e100, smc91x, starfire and the shared code in mii.c).  Unless I'm
> misreading the code it looks like the effect of this option in those
> drivers is to disable autonegotiation but still configure the PHY when
> the NIC is configured.
> 
> That is a subset of what the patch does and isn't sufficient for the
> hardware this patch targets: sometimes there may be a PHY visible on the
> MII bus but with a different configuration to the natsemi or there may
> be no PHY present at all.  In this case the code in the natsemi driver
> that configures the PHY to match the configuration of the natsemi also
> needs to be disabled.
> 
> It looks like I should implement a force_media option and redo this
> patch to use that.

That's the sort of patch I'm looking for...

	Jeff



