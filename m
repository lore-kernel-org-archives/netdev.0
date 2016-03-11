From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 0/2] DT MDIO bus of fixed phys
Date: Sat, 12 Mar 2016 00:36:10 +0100
Message-ID: <20160311233610.GB23969@lunn.ch>
References: <1457737726-23907-1-git-send-email-andrew@lunn.ch>
 <56E35432.2010300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55256 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751549AbcCKXgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 18:36:11 -0500
Content-Disposition: inline
In-Reply-To: <56E35432.2010300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2016 at 03:26:42PM -0800, Florian Fainelli wrote:
> On 11/03/16 15:08, Andrew Lunn wrote:
> > Currently, supporting a fixed-phy in a MAC driver is a bit messy. It
> > needs to be explicit supported, since a fixed phy is somewhat
> > different from a normal phy.
> > 
> > These two patches solve this by making fixed-phys appear as normal
> > PHYs within device tree, allowing them to be referenced by a phandle.
> > Any MAC driver that supports phy-handle can then automatically support
> > a fixed-phy without any code change.
> 
> Humm, if that's the problem we want to solve, we could introduce a
> helper function which tries to locate the phy using a 'phy-handle'
> property

I don't follow you. Where do you get a phandle from to use with
phy-handle?

	Andrew
