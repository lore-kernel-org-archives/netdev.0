From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH 2.6.17-rc6] Remove Prism II support from Orinoco
Date: Sun, 11 Jun 2006 18:27:19 -0400
Message-ID: <20060611222719.GA13139@redhat.com>
References: <20060610175010.GA4617@divinity> <20060610180850.GP7420@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53415 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750917AbWFKW1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2006 18:27:21 -0400
To: Faidon Liambotis <faidon@cube.gr>
Content-Disposition: inline
In-Reply-To: <20060610180850.GP7420@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 10, 2006 at 02:08:50PM -0400, Dave Jones wrote:
 > On Sat, Jun 10, 2006 at 08:50:10PM +0300, Faidon Liambotis wrote:
 >  > Remove Prism II IDs from the orinoco driver since now we have a separate
 >  > driver for them (HostAP). Additionally, kill orinoco_{pci,plx,nortel}
 >  > completely, since they only exist to support Prism cards.
 >  > No attempt was made to clean up the rest of the driver of the actual
 >  > Prism II code, only the PCI IDs were removed.
 > 
 > I'm fairly certain I have a buffalo card that doesn't work with hostap
 > that works just fine with orinoco.  I'll dig it out and see if that
 > has been improved.

Objection rescinded, I have a WLI-PCM-L11G, which this patch doesn't affect.

One question though. People who are currently using orinoco will have
networking scripts set up by their distros autodetection mechanisms to
set up an 'ethX' interface. Switching to hostap by default will change
their interface to a wlanX interface, requiring them to either edit
their networking interface scripts, or to add dev_template parameters
to their /etc/modprobe.conf

Whichever is chosen, the upgrade process is going to blindside end-users
into broken wireless. Maybe things would just transparently keep working
if the default template was also ethX. Though that would cause breakage
for anyone with a currently working 'wlanX' interface on upgrade.

Hmm, tricky.

		Dave

-- 
http://www.codemonkey.org.uk
