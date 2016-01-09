From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH -next 1/2] net: tc35815: Fix build error due to missed
 API change
Date: Sat, 9 Jan 2016 23:09:24 +0100
Message-ID: <20160109220924.GF6877@lunn.ch>
References: <1452374494-18752-1-git-send-email-linux@roeck-us.net>
 <20160109213614.GC6877@lunn.ch>
 <5691808A.1010301@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44652 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756083AbcAIWJ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jan 2016 17:09:26 -0500
Content-Disposition: inline
In-Reply-To: <5691808A.1010301@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >Hi Guenter
> >
> >You fix looks right, but i'm wondering about the code which is being
> >fixed.
> >
> >How can phydev ever evaluate to true, given the break statement?  Can
> >this code every detect multiple PHYs? I think not.
> >
> >Either the break needs to be removed, or we just replace the whole lot
> >with phy_find_first().
> >
> 
> Hi Andrew,
> 
> you are right, the current code is pretty pointless.
> 
> I would suggest to use phy_find_first().

Me too.

> Should I submit a separate patch, or replace my patch with v2 ?

I say a v2 which uses phy_find_first() and include in the changelog
why the current code is pointless and so the change to
phy_find_first().

	Thanks
		Andrew
