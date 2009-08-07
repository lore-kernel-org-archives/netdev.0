From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH] be2net: Implementation of request_firmware interface.
Date: Fri, 07 Aug 2009 02:20:33 -0700
Message-ID: <1249636833.6477.812.camel@localhost>
References: <20090702111820.GA21085@serverengines.com>
	 <1246566808.9821.2.camel@deadeye> <20090705121637.GA3627@serverengines.com>
	 <1246803604.3898.6.camel@deadeye>
Reply-To: linuxram@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sarveshwar Bandi <sarveshwarb@serverengines.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:57259 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918AbZHGJUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 05:20:36 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e39.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n779Fl2q020890
	for <netdev@vger.kernel.org>; Fri, 7 Aug 2009 03:15:47 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n779KbqV214376
	for <netdev@vger.kernel.org>; Fri, 7 Aug 2009 03:20:37 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n779Ka43002643
	for <netdev@vger.kernel.org>; Fri, 7 Aug 2009 03:20:37 -0600
In-Reply-To: <1246803604.3898.6.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-07-05 at 15:20 +0100, Ben Hutchings wrote:
> On Sun, 2009-07-05 at 17:46 +0530, Sarveshwar Bandi wrote:
> > I understand that most drivers  use request_firmware() to load  volatile
> > firmware. I do see that there are other nic drivers that use this inferface to
> > flash persistent firmware.
> > 
> >  We have other tools for offline flashing; but there is requirement
> > to flash f/w through driver without having to use other proprietary  tools.
> 
> The firmware blob is proprietary and has to be distributed separately
> from the kernel.  So does it really matter that you have to distribute a
> special tool as well?
> 
> (Based on requirements specified by major OEMs, I have implemented
> firmware update through the sfc driver (MDIO and MTD interfaces) but
> under the control of a separate tool.)
> 
> > Since the firmware load happens only when there is a version mismatch with
> > f/w in /lib/firmware, Users who want to avoid automatic flashing at boot time
> > can choose not to copy the f/w file under /lib/firmware.
> [...]
> 
> Is there a way of loading the firmware into the controller's RAM but not
> writing it to flash?  That ought to be the default behaviour.
> 

Given that the volatile and non-volatile firmware reside in the same
file, it is not possible for the driver to selectively load the intended
firmware.

However, is this behavior a gating factor for this patch from being
accepted?

RP


> Ben.
> 
-- 
Ram Pai
System X Device-Driver Enablement Lead
Linux Technology Center
Beaverton OR-97006
503-5783752 t/l 7753752
linuxram@us.ibm.com

