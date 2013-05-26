From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: add netnotifier event for upper device
 change
Date: Sat, 25 May 2013 23:14:13 -0700 (PDT)
Message-ID: <20130525.231413.1228840457158928295.davem@davemloft.net>
References: <1369491130-7412-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	alexander.h.duyck@intel.com, xiyou.wangcong@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44533 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753864Ab3EZGOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 May 2013 02:14:14 -0400
In-Reply-To: <1369491130-7412-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sat, 25 May 2013 16:12:10 +0200

> Now when upper device is changed, event is not propagated via RT Netlink
> to userspace. Userspace might never now about the change. Fix this by
> adding upper-device-change notifier event.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Looks good, applied, thanks Jiri.

If someone is looking for a useful project, switching networking over to
a more typed notifier system would be a worthwhile improvement.

It's hard to right now to communicate what changed beyond "action X
happened to this object, you have to check to see exactly how it
changed"

This came up recently with the IFF_NOARP stuff.
