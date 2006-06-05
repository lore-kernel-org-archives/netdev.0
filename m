From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP: removal of unused label
Date: Mon, 05 Jun 2006 16:03:52 -0700 (PDT)
Message-ID: <20060605.160352.21926542.davem@davemloft.net>
References: <20060605110331.0f058738@dxpl.pdx.osdl.net>
	<20060605195549.GA14942@electric-eye.fr.zoreil.com>
	<20060605160240.4951f7ad@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18604
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750703AbWFEXDv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 19:03:51 -0400
To: shemminger@osdl.org
In-Reply-To: <20060605160240.4951f7ad@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 5 Jun 2006 16:02:40 -0700

> rtattr_failure is used inside __RTA_PUT() macro. It's gross, but there are
> those who love it..

Yes, it was clear that this patch wasn't build tested.

And GCC usually warns very loudly about truly unused
labels.
