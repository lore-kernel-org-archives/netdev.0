From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 3/3] Intel IXP4xx network drivers
Date: Tue, 8 May 2007 13:46:26 +0200
Message-ID: <20070508114626.GA32146@xi.wantstofly.org>
References: <m3abwhcy74.fsf@maximus.localdomain> <m3vef5biob.fsf@maximus.localdomain> <5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk> <m3hcqoa772.fsf@maximus.localdomain> <86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk> <m33b289zku.fsf@maximus.localdomain> <33637217-BE44-4E03-A912-F4FE6E14AA6D@cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Halasa <khc@pm.waw.pl>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	ARM Linux Mailing List
	<linux-arm-kernel@lists.arm.linux.org.uk>
To: Michael-Luke Jones <mlj28@cam.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:49959 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967364AbXEHLqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 07:46:30 -0400
Content-Disposition: inline
In-Reply-To: <33637217-BE44-4E03-A912-F4FE6E14AA6D@cam.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 07, 2007 at 09:18:00PM +0100, Michael-Luke Jones wrote:

> >Well, I'm told that (compatible) NPEs are present on other IXP CPUs.
> >Not sure about details.
> 
> If, by a combined effort, we ever manage to create a generic NPE  
> driver for the NPEs found in IXP42x/43x/46x/2000/23xx then the driver  
> should go in arch/arm/npe.c

(Note that the ixp2000 doesn't have NPEs.)

(Both the 2000 and the 23xx have microengines, which are both
supported by arch/arm/common/uengine.c.)


> It's possible, but hard due to the differences in hardware design

The ixp23xx NPEs seem pretty much identical to me to the ixp4xx
NPEs.  There are some minor differences between the ixp2000 and
ixp23xx uengines, but those are easy enough to deal with.


> and the fact that boards based on anything other than 42x are few
> and far between. The vast majority of 'independent' users following
> mainline are likely running on 42x boards.

Sure, ixp23xx hardware is harder to get.  I'm not sure what you mean
by 'independent' users, though.  Are people with non-42x hardware
'dependent' users, and why?


> Thus, for now, I would drop the NPE / QMGR code in arch/arm/mach- 
> ixp4xx/ and concentrate on making it 42x/43x/46x agnostic. One step  
> at a time :)

I'd say that it's up to those who are interested in ixp23xx support
(probably only myself at this point) to add ixp23xx support.
