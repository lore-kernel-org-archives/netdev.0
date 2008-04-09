From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [ANN] WiMAX stack and drivers for Intel WiMAX Link 5050
Date: Wed, 9 Apr 2008 22:31:38 +0200
Message-ID: <20080409203138.GH30885@one.firstfloor.org>
References: <200804011107.38563.inaky@linux.intel.com> <200804081359.03611.inaky@linux.intel.com> <871w5fpnhs.fsf@basil.nowhere.org> <200804091109.25265.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Inaky Perez-Gonzalez
	<public-inaky-VuQAYsv1563Yd54FQh9/CA@hugh.gmane.org>,
	Stephen Hemminger
	<public-stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@hugh.gmane.org>,
	public-wimax-BPSAo7wm5JOHVYUYWc+uSQ@hugh.gmane.org,
	public-linux-wireless-u79uwXL29TY76Z2rM5mHXA@hugh.gmane.org,
	public-netdev-u79uwXL29TY76Z2rM5mHXA@hugh.gmane.org,
	public-linux-kernel-u79uwXL29TY76Z2rM5mHXA@hugh.gmane.org
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blaine.gmane.org ([80.91.229.8]:52263 "EHLO hugh.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753381AbYDIU10 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 16:27:26 -0400
Received: from public by hugh.gmane.org with local (Exim 4.63)
	(envelope-from <public@hugh.gmane.org>)
	id 1Jjgt7-0005ag-BF
	for netdev@vger.kernel.org; Wed, 09 Apr 2008 22:27:21 +0200
Content-Disposition: inline
In-Reply-To: <200804091109.25265.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, Apr 09, 2008 at 11:09:24AM -0700, Inaky Perez-Gonzalez wrote:
> On Tuesday 08 April 2008, Andi Kleen wrote:
> 
> > > version: I anticipate the wimax API exported to user space is
> > > going to undergo a lot of changes while we all agree on what
> > > is the best interface. Because things might break, I want to
> > > make sure user space stuff can detect that and fail cleanly. 
> > > Hence the versioning. 
> > 
> > It's still a bad way to do that (I agree with Stephen on that).
> > Was also always a mess on wireless.
> > 
> > If you don't want expandable TLAs another better alternative to 
> > versions is ext2 style compatible/incompatible feature bitmaps.
> 
> Ain't that another way of saying versions? Sorry guys, but I am 

It's a related way, but an actually sane way.

With compat/incompat bitmaps user space can actually make a educated
decision if it should fail or not

-Andi

