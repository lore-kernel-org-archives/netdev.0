From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [PATCH] DM9000: platform dependent fill_ether_addr method
Date: Fri, 18 Apr 2008 16:21:14 +0100
Message-ID: <20080418152114.GI15407@fluff.org.uk>
References: <1208512936-5897-1-git-send-email-enrico.scholz@sigma-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:65194 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751774AbYDRPVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 11:21:17 -0400
Content-Disposition: inline
In-Reply-To: <1208512936-5897-1-git-send-email-enrico.scholz@sigma-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 18, 2008 at 12:02:14PM +0200, Enrico Scholz wrote:
> This patch adds a fill_ether_addr() method to the DM9000 platform data
> which can be used to fill in the MAC address in a platform specific manner
> (e.g. calculate it out of the serial number).
> 
> This method will be called only, when MAC was not set previously (e.g. by
> bootloader) or can be read out of the EEPROM.

I belive this has come up on the list a number of times before, and
the general answer is that either the bootloader is at fault for not
initialising the chip, the manufacturer should have shoved an EEPROM
on for configuration. The general answer is that the driver should not
be making up for the fault of the system.

I'm not sure if you can pass the mac via a commandline argument, that
is something you'll have to research for yourself.
 
> Having a valid MAC address in early bootstage is necessary e.g. for booting
> from network.

No, you can load an initramfs to set the mac via ethtool and then
continue with the boot.
 
-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
