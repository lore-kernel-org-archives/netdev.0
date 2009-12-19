From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netem/iproute2 solving correlated loss issues [0/5]
Date: Fri, 18 Dec 2009 20:04:06 -0800 (PST)
Message-ID: <20091218.200406.183057577.davem@davemloft.net>
References: <4B2B5BD1.7040602@uniroma2.it>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fabio.ludovici@yahoo.it
To: stefano.salsano@uniroma2.it
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41154
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754975AbZLSEEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 23:04:04 -0500
In-Reply-To: <4B2B5BD1.7040602@uniroma2.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefano Salsano <stefano.salsano@uniroma2.it>
Date: Fri, 18 Dec 2009 11:39:13 +0100

> The patch is backward compatible, we have not removed the previous
> correlated loss generated approach (though its use should be
> deprecated), nor we have changed anything else in the existing netem
> module.

To heck it is!

The changed version of iproute2 will not work without the kernel
changes installed.  The kernel validates the size of the structures
passed in, you can't change the user visible interface like this.

Add new netlink attributes to extend things, that's the "real"
backwards compatible way to make changes to netlink interfaces.
