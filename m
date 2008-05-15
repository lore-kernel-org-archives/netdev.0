From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: dead network on JS21 with tg3 driver after flowcontrol
 changes
Date: Thu, 15 May 2008 10:37:07 -0700
Message-ID: <1210873027.22745.0.camel@dell>
References: <20080515121340.GA23033@aepfle.de>
 <1551EAE59135BE47B544934E30FC4FC002AABCEE@nt-irva-0751.brcm.ad.broadcom.com>
 <20080515154948.GA23647@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>, linuxppc-dev@ozlabs.org,
	netdev <netdev@vger.kernel.org>
To: "Olaf Hering" <olaf@aepfle.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1976 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757315AbYEOQc3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2008 12:32:29 -0400
In-Reply-To: <20080515154948.GA23647@aepfle.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-05-15 at 17:49 +0200, Olaf Hering wrote:
> On Thu, May 15, Michael Chan wrote:
> 
> > Olaf Hering wrote:
> > 
> > > Any ideas how to fix this?
> > > What info do you need from the system?
> > 
> > Are you using eth0 or eth1?  The dmesg below shows that
> > link came up on eth1 and IP address from DHCP was received.
> 
> I'm using eth1.
> The log was done with the patch reverted.
> 

In that case, please re-apply the patch and provide mii-tool -vvv eth1.

