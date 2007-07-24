From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] e1000: repost work around 82571 completion timout on pseries HW
Date: Tue, 24 Jul 2007 12:29:37 -0400
Message-ID: <20070724162936.GB2293@gospo.rdu.redhat.com>
References: <20070724151912.GA2293@gospo.rdu.redhat.com> <46A61B3C.5070808@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60453 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751123AbXGXQ3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 12:29:45 -0400
Content-Disposition: inline
In-Reply-To: <46A61B3C.5070808@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 24, 2007 at 08:31:08AM -0700, Kok, Auke wrote:
> Andy Gospodarek wrote:
> >There seems to have been some discussion about a patch like this in the
> >past but I still haven't noticed any platforms fixes or noticed that
> >this got included, so I'd like to propose this modified version.
> >
> >Thoughts?
> 
> I've written a completely new version for IBM based on the response that 
> implements this as a pci quirk (to tag the chipset, not the device).
> 
> However IBM has spotted an issue due to firmware hiding the id for linux of 
> the bridge involved (on pseries), and they're working on an alternative to 
> fix that.
> 
> So, the patch will look different, and I'll post it as soon as we have a 
> version for both pseries and xseries that works.
> 
> Auke
> 

Sounds great.  I just wanted to make sure this didn't slip through the
cracks.


