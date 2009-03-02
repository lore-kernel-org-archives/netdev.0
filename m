From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH v2] typhoon: Use request_firmware()
Date: Sun, 01 Mar 2009 22:16:47 -0500
Message-ID: <1235963807.27973.1.camel@localhost.localdomain>
References: <20090226134950.GA975@decadentplace.org.uk>
	 <1235939916.22828.7.camel@localhost.localdomain>
	 <1235955774.3251.6.camel@bunthorne.i.decadent.org.uk>
	 <20090301.174433.258919971.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:54634 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751757AbZCBDQv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Mar 2009 22:16:51 -0500
In-Reply-To: <20090301.174433.258919971.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-03-01 at 17:44 -0800, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Mon, 02 Mar 2009 01:02:54 +0000
> 
> > On Sun, 2009-03-01 at 15:38 -0500, David Dillow wrote:
> > > I suppose I better test this sooner rather than later, because I think
> > > you've broken it. The firmware gets vmalloc'd, which means it is not
> > > necessarily physically contiguous, and I don't think pci_map_single() is
> > > going to like that since the firmware is always larger than a page. But
> > > I may be wrong on this.
> > 
> > You could well be right.
> 
> He is definitely right, this cannot work.

Do you want to revert, or do you a patch to fix it? Revert will be
quicker as I have to dig out hardware to test...

