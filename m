From: Michael Buesch <mb@bu3sch.de>
Subject: Re: The new SSB subsystem for bcm43xx (and others)
Date: Sun, 11 Feb 2007 00:10:52 +0100
Message-ID: <200702110010.52586.mb@bu3sch.de>
References: <200612221359.25093.mb@bu3sch.de> <20070210221150.GA28338@srcf.ucam.org> <1171148204.22868.1.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Matthew Garrett <mjg59@srcf.ucam.org>, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de, Felix Fietkau <nbd@nbd.name>
To: Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:44335
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbXBJXL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Feb 2007 18:11:29 -0500
In-Reply-To: <1171148204.22868.1.camel@dv>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 10 February 2007 23:56, Pavel Roskin wrote:
> On Sat, 2007-02-10 at 22:11 +0000, Matthew Garrett wrote:
> > Ok, here's a patch. The stack of PCMCIA headers are needed to get the 
> > pcmcia_device structure. Seems to work fine for PCI - I don't have any 
> > PCMCIA devices. The SSB devices now appear underneath the PCI device 
> > rather than in the top level of /sys/devices.
> 
> I've just checked, pcmcia/ciscode.h is not needed.  The rest is needed.

http://bu3sch.de/gitweb?p=wireless-dev.git;a=commitdiff;h=218241c63246c5611520df98ce8ae06016545c9c

-- 
Greetings Michael.
