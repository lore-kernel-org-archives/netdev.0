From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] typhoon: Use request_firmware()
Date: Sun, 01 Mar 2009 17:44:33 -0800 (PST)
Message-ID: <20090301.174433.258919971.davem@davemloft.net>
References: <20090226134950.GA975@decadentplace.org.uk>
	<1235939916.22828.7.camel@localhost.localdomain>
	<1235955774.3251.6.camel@bunthorne.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave@thedillows.org, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51346
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757160AbZCBBow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 20:44:52 -0500
In-Reply-To: <1235955774.3251.6.camel@bunthorne.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 02 Mar 2009 01:02:54 +0000

> On Sun, 2009-03-01 at 15:38 -0500, David Dillow wrote:
> > I suppose I better test this sooner rather than later, because I think
> > you've broken it. The firmware gets vmalloc'd, which means it is not
> > necessarily physically contiguous, and I don't think pci_map_single() is
> > going to like that since the firmware is always larger than a page. But
> > I may be wrong on this.
> 
> You could well be right.

He is definitely right, this cannot work.
