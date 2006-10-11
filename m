From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [patch 2/3] d80211: remove poorly documented ieee80211_hw extra_hdr_room flag
Date: Tue, 10 Oct 2006 17:37:20 -0700
Message-ID: <20061011003720.GA22038@devicescape.com>
References: <20061009170159.804032000@devicescape.com> <200610101200.12454.mb@bu3sch.de> <20061010134533.GB4518@devicescape.com> <200610102304.05291.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:44249 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1030731AbWJKAhd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 20:37:33 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200610102304.05291.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 10, 2006 at 11:04:05PM +0200, Michael Buesch wrote:
> On Tuesday 10 October 2006 15:45, David Kimdon wrote:
> > On Tue, Oct 10, 2006 at 12:00:12PM +0200, Michael Buesch wrote:
> > > On Monday 09 October 2006 19:03, David Kimdon wrote:
> > > > This flag is unused by all in tree drivers.  Furthermore, the way that
> > > > it is documented is not consistent with the way it is actually used by
> > > > ieee80211.c.  The original attempt appears to be something to do with
> > > > adding extra header room for low-level drivers which need to pad the
> > > > IEEE 802.11 header (example: Atheros).
> > > 
> > > What about not removing it, but extending it.
> > 
> > Sure, I would be happy with that.  For Atheros it will be '2' to
> > ensure that we can properly align the packet in the tx path without
> > needing to realloc. 
> 
> Ok, nice. Do you want to do a patch or should I do?

Go ahead, thanks.

-David
