From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5][SCTP]: Remove multiple levels of msecs to jiffies
 conversions.
Date: Tue, 22 Aug 2006 00:22:53 -0700 (PDT)
Message-ID: <20060822.002253.26973121.davem@davemloft.net>
References: <1155925357.20802.27.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:48098
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751323AbWHVHWi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 03:22:38 -0400
To: sri@us.ibm.com
In-Reply-To: <1155925357.20802.27.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Fri, 18 Aug 2006 11:22:37 -0700

> [SCTP]: Remove multiple levels of msecs to jiffies conversions.
> 
> The SCTP sysctl entries are displayed in milliseconds, but stored
> internally in jiffies. This results in multiple levels of msecs to
> jiffies conversion and as a result produces a truncation error. This
> patch makes things consistent in that we store and display defaults
> in milliseconds and only convert once for use by association.
> This patch also adds some sane min/max values so that we don't go off
> the deep end.
> 
> Signed-off-by: Vladislav Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

This cannot be done.

The syctl values have a fixed format, like any other portion
of the API exposed to userspace.

So you cannot arbitrarily change the units to/from milliseconds
and jiffies.
