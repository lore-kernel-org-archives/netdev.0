From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netdev: smsc911x: allow building on Blackfin
 systems
Date: Mon, 08 Jun 2009 00:10:46 -0700 (PDT)
Message-ID: <20090608.001046.250441946.davem@davemloft.net>
References: <1244248640-22699-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59644
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750946AbZFHHKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 03:10:45 -0400
In-Reply-To: <1244248640-22699-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Fri,  5 Jun 2009 20:37:19 -0400

> The smsc911x driver works fine on Blackfin systems, so add it to the arch
> list in the Kconfig.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Applied.

> side note ... does it even make sense to have this arch list in the first
> place ?  the driver works with any platform who declares proper platform
> resources ...

I agree, we should probably get rid of the conditional arch list.
