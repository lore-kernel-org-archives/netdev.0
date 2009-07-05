From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] be2net: Implementation of request_firmware interface.
Date: Sun, 05 Jul 2009 15:20:04 +0100
Message-ID: <1246803604.3898.6.camel@deadeye>
References: <20090702111820.GA21085@serverengines.com>
	 <1246566808.9821.2.camel@deadeye> <20090705121637.GA3627@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57621 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753583AbZGEOUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 10:20:05 -0400
In-Reply-To: <20090705121637.GA3627@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-07-05 at 17:46 +0530, Sarveshwar Bandi wrote:
> I understand that most drivers  use request_firmware() to load  volatile
> firmware. I do see that there are other nic drivers that use this inferface to
> flash persistent firmware.
> 
>  We have other tools for offline flashing; but there is requirement
> to flash f/w through driver without having to use other proprietary  tools.

The firmware blob is proprietary and has to be distributed separately
from the kernel.  So does it really matter that you have to distribute a
special tool as well?

(Based on requirements specified by major OEMs, I have implemented
firmware update through the sfc driver (MDIO and MTD interfaces) but
under the control of a separate tool.)

> Since the firmware load happens only when there is a version mismatch with
> f/w in /lib/firmware, Users who want to avoid automatic flashing at boot time
> can choose not to copy the f/w file under /lib/firmware.
[...]

Is there a way of loading the firmware into the controller's RAM but not
writing it to flash?  That ought to be the default behaviour.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
