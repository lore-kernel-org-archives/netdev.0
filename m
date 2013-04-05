From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: count hw_addr syncs so that unsync works properly.
Date: Fri, 05 Apr 2013 00:20:04 -0400 (EDT)
Message-ID: <20130405.002004.1687390683331436879.davem@davemloft.net>
References: <1364937007-23894-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888Ab3DEEUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 00:20:06 -0400
In-Reply-To: <1364937007-23894-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Tue,  2 Apr 2013 17:10:07 -0400

> A few drivers use dev_uc_sync/unsync to synchronize the
> address lists from master down to slave/lower devices.  In
> some cases (bond/team) a single address list is synched down
> to multiple devices.  At the time of unsync, we have a leak
> in these lower devices, because "synced" is treated as a
> boolean and the address will not be unsynced for anything after
> the fist device/call.
> 
> Treat "synced" as a count (same as refcount) and allow all
> unsync calls to work.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied and queued up for -stable, thanks Vlad.
