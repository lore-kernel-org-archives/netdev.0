From: David Miller <davem@davemloft.net>
Subject: Re: netlink: remove subscriptions check on notifier
Date: Tue, 17 Nov 2009 04:09:15 -0800 (PST)
Message-ID: <20091117.040915.35189283.davem@davemloft.net>
References: <1258409134.1375.0.camel@johannes.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38131
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754844AbZKQMI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 07:08:58 -0500
In-Reply-To: <1258409134.1375.0.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 16 Nov 2009 23:05:34 +0100

> The netlink URELEASE notifier doesn't notify for
> sockets that have been used to receive multicast
> but it should be called for such sockets as well
> since they might _also_ be used for sending and
> not solely for receiving multicast. We will need
> that for nl80211 (generic netlink sockets) in the
> future.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Applied, let's see what this breaks :-)
