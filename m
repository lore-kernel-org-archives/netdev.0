From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH 1/2] netdev: smsc911x: allow building on Blackfin systems
Date: Mon, 8 Jun 2009 20:36:24 +0100
Message-ID: <OF063E0F2B.DD999013-ON802575CF.006B45BD-802575CF.006BB3F8@smsc.com>
References: <1244248640-22699-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	Ian.Saturley@smsc.com
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:64972 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753698AbZFHThI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2009 15:37:08 -0400
In-Reply-To: <1244248640-22699-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The smsc911x driver works fine on Blackfin systems, so add it to the 
arch
> list in the Kconfig.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Acked-by: Steve Glendinning <steve.glendinning@smsc.com>

> side note ... does it even make sense to have this arch list in the 
first
> place ?  the driver works with any platform who declares proper platform
> resources ...

You're right, there's nothing "special" about ARM | SUPERH other than they 
cover all the in-tree platforms using smsc911x.  The aim was to hide this 
option from menuconfig on x86 etc, where this device is extremely unlikely 
to be found.  Maybe there's a better way of doing this?

Steve
