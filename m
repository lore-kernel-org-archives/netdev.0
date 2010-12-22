From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atl1c: Do not use legacy PCI power management
Date: Wed, 22 Dec 2010 15:26:52 -0800 (PST)
Message-ID: <20101222.152652.246521228.davem@davemloft.net>
References: <201012221407.52615.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com,
	jie.yang@atheros.com
To: rjw@sisk.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43932
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752367Ab0LVX0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 18:26:22 -0500
In-Reply-To: <201012221407.52615.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Wed, 22 Dec 2010 14:07:52 +0100

> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> The atl1c driver uses the legacy PCI power management, so it has to
> do some PCI-specific things in its ->suspend() and ->resume()
> callbacks and they are not done correctly.
> 
> Convert atl1c to the new PCI power management framework and make it
> let the PCI subsystem handle all of the PCI-specific aspects of
> device handling during system power transitions.
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>

Applied to net-2.6, thank you.
