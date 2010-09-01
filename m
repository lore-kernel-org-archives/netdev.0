From: David Miller <davem@davemloft.net>
Subject: Re: ERR_PTR pattern in phylib
Date: Wed, 01 Sep 2010 12:03:49 -0700 (PDT)
Message-ID: <20100901.120349.133893738.davem@davemloft.net>
References: <AANLkTimjVZTNeLdm4qptU1MqREODLASdGGanUyxqxfub@mail.gmail.com>
	<20100901.082729.135524471.davem@davemloft.net>
	<AANLkTimkh6ytDmiCQY-gZLHpLzeux1RwMFyr=HyfcDaJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: grant.likely@secretlab.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38609
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754306Ab0IATDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 15:03:32 -0400
In-Reply-To: <AANLkTimkh6ytDmiCQY-gZLHpLzeux1RwMFyr=HyfcDaJ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>
Date: Wed, 1 Sep 2010 12:56:29 -0600

> The error codes in phylib are almost arbitrary and don't really give
> enough information about where the a failure lies.  dev_err() is more
> useful for debugging.

If it's using bad error codes, that's only indicative of a bug in
phylib.

> How about this as a compromise:  I'll investigate all the users of
> phylib and if I find even one situation where the specific return code
> is actually important to a driver, then I'll back off.  phylib has
> been around for 5 years now which should be enough time for that use
> case to bubble to the surface.

Sorry, I'm not agreeable to this.

If there are bugs where drivers are not checking the return
pointers correctly, please just fix those bugs.  Otherwise
I see things fine as they are.
