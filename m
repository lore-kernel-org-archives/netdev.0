From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] typhoon: Use request_firmware()
Date: Sun, 01 Mar 2009 20:11:23 -0800 (PST)
Message-ID: <20090301.201123.112634333.davem@davemloft.net>
References: <1235955774.3251.6.camel@bunthorne.i.decadent.org.uk>
	<20090301.174433.258919971.davem@davemloft.net>
	<1235963807.27973.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org
To: dave@thedillows.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59431
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755504AbZCBELm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 23:11:42 -0500
In-Reply-To: <1235963807.27973.1.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Dillow <dave@thedillows.org>
Date: Sun, 01 Mar 2009 22:16:47 -0500

> On Sun, 2009-03-01 at 17:44 -0800, David Miller wrote:
> > From: Ben Hutchings <ben@decadent.org.uk>
> > Date: Mon, 02 Mar 2009 01:02:54 +0000
> > 
> > > On Sun, 2009-03-01 at 15:38 -0500, David Dillow wrote:
> > > > I suppose I better test this sooner rather than later, because I think
> > > > you've broken it. The firmware gets vmalloc'd, which means it is not
> > > > necessarily physically contiguous, and I don't think pci_map_single() is
> > > > going to like that since the firmware is always larger than a page. But
> > > > I may be wrong on this.
> > > 
> > > You could well be right.
> > 
> > He is definitely right, this cannot work.
> 
> Do you want to revert, or do you a patch to fix it? Revert will be
> quicker as I have to dig out hardware to test...

Give me a fix so I don't have to revert.
