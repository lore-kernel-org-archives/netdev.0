From: David Miller <davem@davemloft.net>
Subject: Re: Bluetooth fixes for 2.6.27
Date: Mon, 08 Sep 2008 19:42:09 -0700 (PDT)
Message-ID: <20080908.194209.111481398.davem@davemloft.net>
References: <1220910837.11655.28.camel@californication>
	<20080908.170516.176909371.davem@davemloft.net>
	<0E7517ED-A2C3-4DFB-9733-0DAEA82F3815@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48315
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754541AbYIICmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 22:42:15 -0400
In-Reply-To: <0E7517ED-A2C3-4DFB-9733-0DAEA82F3815@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Tue, 9 Sep 2008 04:04:02 +0200

[ Please type enter every 80 columns... please! ]

> >> The second patch fixes the authentication requirements. We do have to
> >> separate between service discovery and actual profile channels. This is
> >> a clear requirement of the Bluetooth Security Mode 4 introduced with the
> >> addition of the Simple Pairing support. Not fixing this will result in
> >> broken behavior when doing service discovery with Simple Pairing enabled
> >> devices.
> >
> > What regression reported by a user is fixed by this?
> >
> > This does not look like it is appropriate outside of the merge window.
>
> the regression is that with Bluetooth 2.0 and before we always were
> allowing service discovery (SDP) connection without any bonding
> requirement. This is still true, but with Bluetooth 2.1 enabled
> devices it can now happen that we have to do a full pairing
> procedure. For SDP it should be at least using pairing with a
> just-works model with the no bonding requirement, while the other
> PSM channels (RFCOMM, BNEP etc.) should use generic bonding. We
> would now always use generic bonding (even for SDP).
>
> The number of users are still limited to a few people actually
> testing with 2.1 hardware. These are mainly people working on 2.1
> enabled products. However with the new MacBooks and the EeePC 901 we
> do have devices with Bluetooth 2.1 chips available for everybody.
>
> This is clearly an oversight on my hand when developing the initial
> Simple Pairing patches that I submitted for 2.6.27-rc1 and I only
> found it when we tested against the official Bluetooth 2.1 test
> system.

This is the core issue, if it regresses from 2.6.26, and if so you should
mention that somewhere.  Best would be in the commit message itself.

Then I wouldn't have had to ask you anything.

But instead you're having to describe it for me here in this email, which
nobody can see when scanning the GIT commit messages, so it essentially
might as well not even exist.
