From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] r8169: partial support and phy init for the 8168d
Date: Mon, 2 Nov 2009 19:06:18 +0000
Message-ID: <20091102190618.GM4236@decadent.org.uk>
References: <20091007224420.GA20170@electric-eye.fr.zoreil.com> <1257092683.3136.325.camel@localhost> <20091101.224645.262714217.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	edward_hsu@realtek.com.tw
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52330 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756641AbZKBTGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 14:06:19 -0500
Content-Disposition: inline
In-Reply-To: <20091101.224645.262714217.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 01, 2009 at 10:46:45PM -0800, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Sun, 01 Nov 2009 16:24:43 +0000
> 
> > I believe this is patching machine code in the PHY.  And we do not have
> > source for that code, so it cannot possibly be distributed under GPL.
> 
> You don't know if it's machine code or some data values that
> are used to control the PHY's execution.

No, I don't know that this is machine code.  But you are setting up
a false opposition: 'data values that are used to control the PHY's
execution' certainly include the machine code that it executes.

> In fact I would really be surprised if they had some cpu interpeting
> code in the 8168d PHY.

Your knowledge of PHYs may be outdated.  1000BASE-T has to be done
with a mixture of analog and digital signal processing, since analog
alone would be too power-hungry.  While autonegotiation and power
management could be hardwired it's less risky to put in a micro-
controller and finalise the firmware after the silicon... or even
after release, as seems to have happened here.

> You did do some research about that before making such accusations
> right? :-)

I began with 'I believe'.  It's not an accusation.

Ben.

-- 
Ben Hutchings
Sturgeon's Law: Ninety percent of everything is crap.
