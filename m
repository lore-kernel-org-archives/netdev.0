From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 0/2] Add suppport for sync of hw addresses to
 multiple devices.
Date: Mon, 15 Apr 2013 16:12:48 -0400 (EDT)
Message-ID: <20130415.161248.1709223661580314155.davem@davemloft.net>
References: <1366055666-12916-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36010 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753095Ab3DOUMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 16:12:51 -0400
In-Reply-To: <1366055666-12916-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Mon, 15 Apr 2013 15:54:24 -0400

> Current dev_[uc|mc]_addr_sync() API currently correctly syncs the
> addresses to the first device.  Any subsequent calls to sync will
> not do anything since the synched variable will be set.  This
> variable is used as an optimization to skip over addresses that have
> been synched.
> 
> There are some devices (ex: team) that attempt to do the above.  There
> is other work in progress that needs to above to work corretly.
> 
> The short series introduces dev_[uc|mc]_addr_synch_multiple() that
> allows multiple calls to sync to multiple different devices.  Original
> API is left alone and still has the limitation.

Looks good, applied to net-next, thanks!
