From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netdev: smsc911x: add missing __devexit_p() usage
Date: Mon, 08 Jun 2009 00:10:52 -0700 (PDT)
Message-ID: <20090608.001052.164131659.davem@davemloft.net>
References: <1244248640-22699-1-git-send-email-vapier@gentoo.org>
	<1244248640-22699-2-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59648
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750758AbZFHHKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 03:10:51 -0400
In-Reply-To: <1244248640-22699-2-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Fri,  5 Jun 2009 20:37:20 -0400

> The smsc911x_drv_remove() function is declared with __devexit, so the
> assignment to the driver structure needs __devexit_p() wrappings to prevent
> build failure when hotplug is disabled.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Applied.
