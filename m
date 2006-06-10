From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH 2.6.17-rc6] Remove Prism II support from Orinoco
Date: Sat, 10 Jun 2006 14:08:50 -0400
Message-ID: <20060610180850.GP7420@redhat.com>
References: <20060610175010.GA4617@divinity>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43412 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751661AbWFJSIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2006 14:08:52 -0400
To: Faidon Liambotis <faidon@cube.gr>
Content-Disposition: inline
In-Reply-To: <20060610175010.GA4617@divinity>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 10, 2006 at 08:50:10PM +0300, Faidon Liambotis wrote:
 > Remove Prism II IDs from the orinoco driver since now we have a separate
 > driver for them (HostAP). Additionally, kill orinoco_{pci,plx,nortel}
 > completely, since they only exist to support Prism cards.
 > No attempt was made to clean up the rest of the driver of the actual
 > Prism II code, only the PCI IDs were removed.

I'm fairly certain I have a buffalo card that doesn't work with hostap
that works just fine with orinoco.  I'll dig it out and see if that
has been improved.

		Dave

-- 
http://www.codemonkey.org.uk
