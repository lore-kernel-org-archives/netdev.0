From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] socket: SOCK_DEBUG type checking
Date: Fri, 21 Mar 2008 15:56:00 -0700 (PDT)
Message-ID: <20080321.155600.121386813.davem@davemloft.net>
References: <20080321075132.2fe4ac23@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32957
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763626AbYCUWzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 18:55:45 -0400
In-Reply-To: <20080321075132.2fe4ac23@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 21 Mar 2008 07:51:32 -0700

> Use the inline trick (same as pr_debug) to get checking
> of debug statements even if no code is generated.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, and I'll push to net-2.6.26 after some build
testing.

Although the use of SOCK_DEBUG is so esoteric and sparse,
I can't see how any of it can be useful for any kind of
debugging.

I'd say we should just remove this thing.
