From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] be2net: Implementation of request_firmware interface.
Date: Fri, 07 Aug 2009 14:20:13 +0100
Message-ID: <1249651213.2781.0.camel@achroite>
References: <20090702111820.GA21085@serverengines.com>
	 <1246566808.9821.2.camel@deadeye> <20090705121637.GA3627@serverengines.com>
	 <1246803604.3898.6.camel@deadeye>  <1249636833.6477.812.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sarveshwar Bandi <sarveshwarb@serverengines.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: linuxram@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:36256 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752019AbZHGNUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 09:20:23 -0400
In-Reply-To: <1249636833.6477.812.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-08-07 at 02:20 -0700, Ram Pai wrote:
> On Sun, 2009-07-05 at 15:20 +0100, Ben Hutchings wrote:
> > On Sun, 2009-07-05 at 17:46 +0530, Sarveshwar Bandi wrote:
> > > I understand that most drivers  use request_firmware() to load  volatile
> > > firmware. I do see that there are other nic drivers that use this inferface to
> > > flash persistent firmware.
> > > 
> > >  We have other tools for offline flashing; but there is requirement
> > > to flash f/w through driver without having to use other proprietary  tools.
> > 
> > The firmware blob is proprietary and has to be distributed separately
> > from the kernel.  So does it really matter that you have to distribute a
> > special tool as well?
> > 
> > (Based on requirements specified by major OEMs, I have implemented
> > firmware update through the sfc driver (MDIO and MTD interfaces) but
> > under the control of a separate tool.)
> > 
> > > Since the firmware load happens only when there is a version mismatch with
> > > f/w in /lib/firmware, Users who want to avoid automatic flashing at boot time
> > > can choose not to copy the f/w file under /lib/firmware.
> > [...]
> > 
> > Is there a way of loading the firmware into the controller's RAM but not
> > writing it to flash?  That ought to be the default behaviour.
> > 
> 
> Given that the volatile and non-volatile firmware reside in the same
> file, it is not possible for the driver to selectively load the intended
> firmware.

Your design error is your problem.

> However, is this behavior a gating factor for this patch from being
> accepted?

I'm not a gatekeeper; ask David Miller.

Ben.
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

