From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] phylib: Make PHYs children of their MDIO bus, not the
 bus' parent.
Date: Fri, 20 Nov 2015 00:04:08 +0100
Message-ID: <20151119230408.GB5044@lunn.ch>
References: <1440198963-20080-1-git-send-email-ddaney.cavm@gmail.com>
 <564E3659.1040709@cogentembedded.com>
 <20151119210651.GA5044@lunn.ch>
 <564E4014.3010702@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Daney <ddaney.cavm@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	David Daney <david.daney@cavium.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Grant Likely <grant.likely@secretlab.ca>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37759 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030188AbbKSXEM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Nov 2015 18:04:12 -0500
Content-Disposition: inline
In-Reply-To: <564E4014.3010702@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >What phy is it?
> 
>    Micrel KSZ8041RNLI for sh_eth, KSZ9031 for ravb.
> 
> >Do you have phy DT properties in the MAC node?
> 
>    I have PHY subnodes (with props) in the MAC node.

O.K, so this could be the same problems as

https://lkml.org/lkml/2015/10/15/726

https://www.mail-archive.com/netdev@vger.kernel.org/msg83183.html

We never got a resolution to that problem.

It needs somebody with none working hardware to do some debugging to
figure out exactly what is going on and why my idea to fix it does not
work.

	Andrew
