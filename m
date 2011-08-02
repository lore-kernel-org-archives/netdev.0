From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: PHY down?
Date: Tue, 02 Aug 2011 13:38:02 +0100
Message-ID: <1312288682.2752.7.camel@bwh-desktop>
References: <OF6D5A2ABF.61D9AA63-ONC12578E0.00335EE4-C12578E0.0033AE22@transmode.se>
	 <1312282868.2591.68.camel@deadeye>
	 <OFEC77B7FA.1BCB17E8-ONC12578E0.0043754B-C12578E0.00441F36@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25098 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754255Ab1HBMiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2011 08:38:05 -0400
In-Reply-To: <OFEC77B7FA.1BCB17E8-ONC12578E0.0043754B-C12578E0.00441F36@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-08-02 at 14:24 +0200, Joakim Tjernlund wrote:
> Ben Hutchings <bhutchings@solarflare.com> wrote on 2011/08/02 13:01:08:
> >
> > On Tue, 2011-08-02 at 11:24 +0200, Joakim Tjernlund wrote:
> > > I must be missing something obvious but I cannot find how
> > > to bring eth0's PHY down (link down) from user space.
> > > Tried various settings with ethtool and ifconfig eth0 down but it didn't help.
> >
> > If you configure an interface down, and if the interface is not used for
> > remote management, then some drivers will turn the PHY off.  But there
> > is no general way to control this explicitly.
> 
> OK, when to stop the PHY doesn't seem standardized. Seem logical to me
> to also turn off the PHY when interface is configured down. Perhaps this could
> be agreed upon?
> What does remote management mean? How do I identify if the I/F is used for remote management?

Most server motherboards have some sort of lights-out management (LOM)
faclity.  This is usually accessible when the server is switched on, as
well.  It may share a network port or ports with the host OS.

There is no general way to tell whether this is supported or enabled on
an interface, but it should be described in motherboard documentation or
the firmware configuration program (BIOS setup).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

