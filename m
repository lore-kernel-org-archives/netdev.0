From: bert hubert <bert.hubert@netherlabs.nl>
Subject: Re: [PATCH] tcp: set congestion default through Kconfig (v2)
Date: Tue, 19 Sep 2006 23:38:01 +0200
Message-ID: <20060919213801.GA13543@outpost.ds9a.nl>
References: <20060918214104.3824a2e2@localhost.localdomain> <20060919.123352.124082859.davem@davemloft.net> <20060919134132.44d4da5d@localhost.localdomain> <20060919.142007.06541289.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([213.244.168.210]:55947 "EHLO outpost.ds9a.nl")
	by vger.kernel.org with ESMTP id S1750769AbWISViD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 17:38:03 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060919.142007.06541289.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 19, 2006 at 02:20:07PM -0700, David Miller wrote:

> > Bert's attempt was noble
> > It showed your desire for the truth

It was also crap :-)

> Applied, but...
> net/ipv4/Kconfig:607:warning: defaults for choice values not supported

It does appear to do the right thing in all cases I throw against it, but
this warning is sure to generate noise.

It probably means CONFIG_BIC is both available in the menu, and set as a
separate option, and that this does not set the menu to CONFIG_BIC. This is
not a big deal however as the menu is not shown at all whenever line 607
applies.


-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
