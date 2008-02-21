From: David Miller <davem@davemloft.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Thu, 21 Feb 2008 02:03:43 -0800 (PST)
Message-ID: <20080221.020343.190715910.davem@davemloft.net>
References: <1203586467.20345.14.camel@brick>
	<1203587699.17534.135.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: harvey.harrison@gmail.com, joe@perches.com, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38024
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752495AbYBUKDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 05:03:06 -0500
In-Reply-To: <1203587699.17534.135.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 21 Feb 2008 10:54:59 +0100

> It modifies the buffer, and I think it's more likely that the warning
> was introduced by
 ...
>     [NET]: Elminate spurious print_mac() calls.

Right and that's what I just suggested in another reply.

Harvey how did you "narrow it down" to Joe's patch?  Did you really
bisect to figure it out, or did you just guess?  You said "commit X
introduced" and if you really didn't bisect it down to that
such a claim is very misleading.

Thanks.
