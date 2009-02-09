From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: Fix unicast filter overflow
Date: Sun, 08 Feb 2009 17:48:54 -0800 (PST)
Message-ID: <20090208.174854.51245719.davem@davemloft.net>
References: <20090207174404.16716.20574.stgit@kvm.aw>
	<20090208.170605.01154488.davem@davemloft.net>
	<1234143837.20601.11.camel@2710p.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maxk@qualcomm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: alex.williamson@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58678
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752934AbZBIBtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2009 20:49:00 -0500
In-Reply-To: <1234143837.20601.11.camel@2710p.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Williamson <alex.williamson@hp.com>
Date: Sun, 08 Feb 2009 18:43:57 -0700

> Sure, that's another option, but we'd then need to figure out what to do
> with TUN_FLT_ALLMULTI.  Unicast would almost needs it's own hash list if
> we want to support an allmulti mode that's less than promiscuous.  The
> return value of the ioctl is the number of exact filters, so the user
> will know what happened.

Oh so that's what the return value means.

Ok, I guess for now your patch is fine, I'll apply it and
queue it up for -stable, thanks!

