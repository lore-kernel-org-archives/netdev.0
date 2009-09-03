From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net/ethtool: Add support for the ethtool
 feature to flash firmware image from a specified file.
Date: Wed, 02 Sep 2009 22:43:59 -0700 (PDT)
Message-ID: <20090902.224359.256829926.davem@davemloft.net>
References: <20090903030241.GA19390@serverengines.com>
	<4A9F550D.1090105@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ajitk@serverengines.com, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34348
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754225AbZICFnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 01:43:45 -0400
In-Reply-To: <4A9F550D.1090105@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jgarzik@pobox.com>
Date: Thu, 03 Sep 2009 01:33:01 -0400

> It passes a _filepath_ directly into the kernel?  That seems quite
> wrong...
> 
> we fixed kernel drivers to _not_ think they could read directly from
> the userland filesystem many years ago.
> 
> Seems like passing in an mmap'd fd would be far preferable.

Jeff, it's passing in something that's going to requested via
the firmware loading infrastructure in the kernel.

It is the most appropriate way to do this.
