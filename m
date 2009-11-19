From: Patrick McHardy <kaber@trash.net>
Subject: Re: netlink: remove subscriptions check on notifier
Date: Thu, 19 Nov 2009 15:22:38 +0100
Message-ID: <4B0554AE.1070100@trash.net>
References: <1258409134.1375.0.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43407 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbZKSOWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 09:22:33 -0500
In-Reply-To: <1258409134.1375.0.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg wrote:
> The netlink URELEASE notifier doesn't notify for
> sockets that have been used to receive multicast
> but it should be called for such sockets as well
> since they might _also_ be used for sending and
> not solely for receiving multicast. We will need
> that for nl80211 (generic netlink sockets) in the
> future.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> Cc: Patrick McHardy <kaber@trash.net>

I've audited all users of this (all within netfilter) and this
change makes sense for them as well.

Acked-by: Patrick McHardy <kaber@trash.net>
