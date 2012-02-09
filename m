From: Peter Meerwald <pmeerw@pmeerw.net>
Subject: Re: [PATCH 1/2] smsc95xx: add module parameter to turn off NIC status
 leds
Date: Thu, 9 Feb 2012 10:38:15 +0100 (CET)
Message-ID: <alpine.DEB.2.01.1202091024250.8085@pmeerw.net>
References: <1328699332-9024-1-git-send-email-pmeerw@pmeerw.net> <20120208.152624.1844477840327789365.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.pmeerw.net ([87.118.82.44]:41113 "EHLO pmeerw.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751429Ab2BIJpH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 04:45:07 -0500
In-Reply-To: <20120208.152624.1844477840327789365.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

> > add module parameter to allow to turn off NIC status leds (link, 
> > speed, activity); blinking LEDs are annoying outside the server room :)

> No.  Create a generic mechanism, perhaps via ethtool, for users to
> configure something like this.
 
> Otherwise the next driver that wants to provide this kind of knob
> will add yet another module parameter with yet another name, and
> this kind of ad-hoc set of interfaces absolutely sucks for users.

I am not sure how many NICs provide that functionality, so a specific knob 
seemed reasonable

I had a look at ethtool, there are ETHTOOL_GFLAGS and ETHTOOL_GPFLAGS (and 
the respective setters) which could be used -- but noone seems to use 
those for any purpose 

a private flag for LED control (via ETHTOOL_GPFLAGS) is pretty much the 
same knob as a module parameter, so not an option

so the remaining option is to add something like ETHTOOL_GLEDCONTROL / 
ETHTOOL_SLEDCONTROL with likely only one user (smsc95xx)

regards, p.

-- 

Peter Meerwald
+43-664-2444418 (mobile)
