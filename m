From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2010-06-16
Date: Wed, 16 Jun 2010 11:50:08 -0700 (PDT)
Message-ID: <20100616.115008.226776050.davem@davemloft.net>
References: <20100616182847.GB3138@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43756
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932615Ab0FPSt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 14:49:57 -0400
In-Reply-To: <20100616182847.GB3138@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 16 Jun 2010 14:28:48 -0400

> Here is another passel of of fixes intended for 2.6.35.  Included are
> some build warning fixes, a PCI identifier, a fix for premature
> IRQs during hostap initialization, a fix for a warning caused by
> failing to cancel a scan watchdog in iwlwifi, a fix for a null
> pointer dereference in iwlwifi, and a fix for a race condition in
> the same driver.  Also included is the MAINTAINERS change for the
> orphaning of the older Intel wireless drivers.  All but the last few
> warning fixes have spent some time in linux-next already.
> 
> Please let me know if there are problems!

The patches removing unused function variables just to kill compile
warnings are not appropriate, _at_ _all_.  They don't fix any real
bug, and they definitely don't fix entries in the regression list do
they?

Kill all of those and resend this pull request.

Thanks.
