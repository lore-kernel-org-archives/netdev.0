From: David Miller <davem@davemloft.net>
Subject: Re: e1000 performance issue in 4 simultaneous links
Date: Fri, 11 Jan 2008 17:41:09 -0800 (PST)
Message-ID: <20080111.174109.57502326.davem@davemloft.net>
References: <36D9DB17C6DE9E40B059440DB8D95F5204275B04@orsmsx418.amr.corp.intel.com>
	<20080110.172830.16409182.davem@davemloft.net>
	<m3ir20ipoz.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: benny+usenet@amorsen.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35635
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757175AbYALBlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 20:41:09 -0500
In-Reply-To: <m3ir20ipoz.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benny Amorsen <benny+usenet@amorsen.dk>
Date: Fri, 11 Jan 2008 12:09:32 +0100

> David Miller <davem@davemloft.net> writes:
> 
> > No IRQ balancing should be done at all for networking device
> > interrupts, with zero exceptions.  It destroys performance.
> 
> Does irqbalanced need to be taught about this?

The userland one already does.

It's only the in-kernel IRQ load balancing for these (presumably
powerpc) platforms that is broken.
