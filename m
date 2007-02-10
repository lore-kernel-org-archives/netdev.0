From: Pavel Roskin <proski@gnu.org>
Subject: Re: The new SSB subsystem for bcm43xx (and others)
Date: Sat, 10 Feb 2007 17:56:44 -0500
Message-ID: <1171148204.22868.1.camel@dv>
References: <200612221359.25093.mb@bu3sch.de>
	 <20070210204630.GA27274@srcf.ucam.org> <200702102203.57411.mb@bu3sch.de>
	 <20070210221150.GA28338@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de, Felix Fietkau <nbd@nbd.name>
To: Matthew Garrett <mjg59@srcf.ucam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:35513 "EHLO
	fencepost.gnu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072AbXBJW4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Feb 2007 17:56:49 -0500
Received: from proski by fencepost.gnu.org with local (Exim 4.60)
	(envelope-from <proski@gnu.org>)
	id 1HG181-0006Ce-7C
	for netdev@vger.kernel.org; Sat, 10 Feb 2007 17:55:33 -0500
In-Reply-To: <20070210221150.GA28338@srcf.ucam.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-02-10 at 22:11 +0000, Matthew Garrett wrote:
> Ok, here's a patch. The stack of PCMCIA headers are needed to get the 
> pcmcia_device structure. Seems to work fine for PCI - I don't have any 
> PCMCIA devices. The SSB devices now appear underneath the PCI device 
> rather than in the top level of /sys/devices.

I've just checked, pcmcia/ciscode.h is not needed.  The rest is needed.

-- 
Regards,
Pavel Roskin

