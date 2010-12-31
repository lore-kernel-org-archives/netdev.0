From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Do not use legacy PCI power management
Date: Fri, 31 Dec 2010 11:14:40 -0800 (PST)
Message-ID: <20101231.111440.28810446.davem@davemloft.net>
References: <201012252356.23424.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com,
	linux-pm@lists.linux-foundation.org
To: rjw@sisk.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41246
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754183Ab0LaTOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 14:14:10 -0500
In-Reply-To: <201012252356.23424.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Sat, 25 Dec 2010 23:56:23 +0100

> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> The tg3 driver uses the legacy PCI power management, so it has to do
> some PCI-specific things in its ->suspend() and ->resume() callbacks,
> which isn't necessary and should better be done by the PCI
> sybsystem-level power management code.
> 
> Convert tg3 to the new PCI power management framework and make it
> let the PCI subsystem take care of all the PCI-specific aspects of
> device handling during system power transitions.
> 
> Tested on HP nx6325 with a NetXtreme BCM5788 adapter.
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>

Applied.
