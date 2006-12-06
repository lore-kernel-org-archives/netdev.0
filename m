From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: [PATCH] softmac: Fixed handling of deassociation from AP
Date: Wed, 6 Dec 2006 22:51:01 +0100
Message-ID: <20061206215101.GA24100@p15091797.pureserver.info>
References: <4576D778.mailLQC18T1PN@lwfinger.net> <200612061852.04216.mb@bu3sch.de> <20061206201715.GA23021@p15091797.pureserver.info> <200612062152.36475.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>,
	John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:63631 "EHLO
	p15091797.pureserver.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937664AbWLFVvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 16:51:02 -0500
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200612062152.36475.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-12-06 21:52 Michael Buesch wrote:

> On Wednesday 06 December 2006 21:17, Ulrich Kunitz wrote:
> > On 06-12-06 18:52 Michael Buesch wrote:
> > 
> > > All data in mac->associnfo is protected by mac->associnfo->mutex
> > > and _not_ mac->lock.
> > 
> > Are you sure?
> 
> Yes I am.
> 
> > One can find for instance the following function in 
> > ieee80211softmac_assoc.c:
> 
> This is not the first time we notice that locking
> is completely broken in softmac. ;)

So the right thing would be to add another work function
(*_start_reassoc_work) which sets the associating variable and
calls then *_assoc_work? 

Uli

-- 
Uli Kunitz
