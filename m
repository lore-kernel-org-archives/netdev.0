From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 5/5] net: dsa: bcm_sf2: Register our slave
 MDIO bus
Date: Tue, 7 Jun 2016 20:44:20 +0200
Message-ID: <20160607184420.GB28994@lunn.ch>
References: <1465254895-11152-1-git-send-email-f.fainelli@gmail.com>
 <1465254895-11152-6-git-send-email-f.fainelli@gmail.com>
 <87oa7dxdis.fsf@ketchup.mtl.sfl>
 <87r3c9vtay.fsf@ketchup.mtl.sfl>
 <20160607170050.GA28994@lunn.ch>
 <87oa7cx5sx.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	davem@davemlof.net
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36052 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161597AbcFGSoY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 14:44:24 -0400
Content-Disposition: inline
In-Reply-To: <87oa7cx5sx.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > With the legacy interface it is tricky. When would you call such a
> > remove/tairdown function when using the old binding?
> 
> That'd go in dsa_switch_destroy I guess, but it just covers the case
> where the whole DSA code is unloaded...

I don't think that helps you. It should not be possible to unload the
DSA core while there is an active driver. The drivers needs to unload
first....

	Andrew
