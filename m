From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Bluetooth fixes for 2.6.27
Date: Tue, 09 Sep 2008 06:46:01 +0200
Message-ID: <1220935561.13336.2.camel@californication>
References: <0E7517ED-A2C3-4DFB-9733-0DAEA82F3815@holtmann.org>
	 <20080908.194209.111481398.davem@davemloft.net>
	 <1220934481.11655.32.camel@californication>
	 <20080908.213050.176981752.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:58392 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbYIIEpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 00:45:39 -0400
In-Reply-To: <20080908.213050.176981752.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> > > > The number of users are still limited to a few people actually
> > > > testing with 2.1 hardware. These are mainly people working on 2.1
> > > > enabled products. However with the new MacBooks and the EeePC 901 we
> > > > do have devices with Bluetooth 2.1 chips available for everybody.
> > > >
> > > > This is clearly an oversight on my hand when developing the initial
> > > > Simple Pairing patches that I submitted for 2.6.27-rc1 and I only
> > > > found it when we tested against the official Bluetooth 2.1 test
> > > > system.
> > > 
> > > This is the core issue, if it regresses from 2.6.26, and if so you should
> > > mention that somewhere.  Best would be in the commit message itself.
> > > 
> > > Then I wouldn't have had to ask you anything.
> > > 
> > > But instead you're having to describe it for me here in this email, which
> > > nobody can see when scanning the GIT commit messages, so it essentially
> > > might as well not even exist.
> > 
> > I thought that I did describe this properly in the commit message, but
> > it could also only be clear to me. Do you want me to fix up the commit
> > message with more details?
> 
> Where in your commit message did you specifically state and explain
> that this problem is specifically a regression against 2.6.26?  I didn't
> catch that part.

it was the "... L2CAP PSM 1 (used by SDP) the just-works model ..." and
I admit, after you pointing my nose on it, that it is not clear to
anybody not deeply into this Bluetooth 2.1 stuff.

Let me fix up the tree and have this commit with a better explanation
what it is all about.

Regards

Marcel


