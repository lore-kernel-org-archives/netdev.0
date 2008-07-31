From: David Miller <davem@davemloft.net>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Thu, 31 Jul 2008 03:47:37 -0700 (PDT)
Message-ID: <20080731.034737.154058020.davem@davemloft.net>
References: <20080730.145727.07367670.davem@davemloft.net>
	<20080730151316.a4d76fe9.akpm@linux-foundation.org>
	<1217500776.3454.136.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org,
	thomas.petazzoni@free-electrons.com, shemminger@vyatta.com,
	jeff@garzik.org, netdev@vger.kernel.org, mpm@selenic.com
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54846
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753462AbYGaKrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 06:47:37 -0400
In-Reply-To: <1217500776.3454.136.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Thu, 31 Jul 2008 11:39:36 +0100

> Dave, if you won't take these patches then I will (after review) put
> them in the embedded-2.6 tree with Andrew's sign-off, and ask Linus to
> pull them into 2.6.28 directly from there rather than via your tree.
> I think he'll take them, because it's the right thing to do.

If you're going to force the issue, that's quite nice of you.  And I'm
also glad that you have the one true and only correct view of what is
"the right thing to do" in the Linux networking.

I especially appreciate that you still haven't accepted the plain fact
that CONFIG_ETHTOOL needs to be selected by CONFIG_INET.

I definitely see the next consequence of the CONFIG_ETHTOOL stuff, and
that's a set of ifdef'ola in all the drivers to config out the
per-driver ethtool support code.
