From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Mark COMPAT_NET_DEV_OPS option for removal
Date: Sun, 24 May 2009 14:34:08 -0700 (PDT)
Message-ID: <20090524.143408.192977030.davem@davemloft.net>
References: <1243088259-16482-1-git-send-email-a.beregalov@gmail.com>
	<20090523074143.445ef830@nehalam>
	<20090523081221.61709ec5@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.beregalov@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56199
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752534AbZEXVeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 May 2009 17:34:09 -0400
In-Reply-To: <20090523081221.61709ec5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sat, 23 May 2009 08:12:21 -0700

> Mark the flag as deprecated and default off so users won't use it
> by default. Make the message that was a informational into a full
> warning with backtrace, so any usage gets noticed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

NAK, we're just going to toss this now in 2.6.31, there
is nothing to gain by keeping this stuff around.  It's
an internal API change rather than something visible to
users.

And it results in a clear compilation error for stale
external code not yet converted.
