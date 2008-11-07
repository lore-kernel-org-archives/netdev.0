From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 0/3] WOL fixes for e1000e, e1000 and igb (was: Re: [Bugme-new] [Bug 11865] New: WOL for E100 Doesn't Work Anymore)
Date: Fri, 7 Nov 2008 01:18:02 +0100
Message-ID: <200811070118.03079.rjw@sisk.pl>
References: <bug-11865-10286@http.bugzilla.kernel.org/> <200811041740.50426.rjw@sisk.pl> <F169D4F5E1F1974DBFAFABF47F60C10A0E874918@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	"jeff@garzik.org" <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"rogerx@sdf.lonestar.org" <rogerx@sdf.lonestar.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:33230 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754195AbYKGANY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 19:13:24 -0500
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A0E874918@orsmsx507.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, 5 of November 2008, Brandeburg, Jesse wrote:
> Rafael J. Wysocki wrote:
> > On Tuesday, 4 of November 2008, Rafael J. Wysocki wrote:
> > [--snip--]
> >> 
> >>> Your work is appeciated, I just didn't realize it would break all
> >>> devices that didn't implement it.
> >> 
> >> In fact it doesn't really break them, you can write 'enabled' to
> >> /sys/devices/.../power/wakeup of the device in question and it will
> >> work. 
> >> 
> >>> I'm open to corrections to my point of view above.
> >> 
> >> Well, before those changes WOL didn't work on any of my machines and
> >> now it works on all of them (except for one that hasn't been tested)
> >> - with the already merged patches and the two waiting for merging.
> >> 
> >> Sorry about the problems caused, I'm willing to fix them ASAP.
> > 
> > BTW, WOL fixes for e1000e, e1000 and igb follow.
> 
> Awesome!  Thanks, we are testing them now and will ack/push upstream in
> a couple of days (for sure by end of week)
> 
> So do you have a count of how many other drivers would need this fix
> (regardless of when you'll get to them).

Well, about 20, not including the ones which are OK now and for which patches
have been sent.
