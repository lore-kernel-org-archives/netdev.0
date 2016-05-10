From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix a kernel infoleak in x25 module
Date: Mon, 09 May 2016 22:47:02 -0400 (EDT)
Message-ID: <20160509.224702.1025080380497378551.davem@davemloft.net>
References: <1462723814-14732-1-git-send-email-kjlu@gatech.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew.hendry@gmail.com, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	taesoo@gatech.edu, insu@gatech.edu, csong84@gatech.edu,
	kjlu@gatech.edu
To: kangjielu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36271 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbcEJCrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 22:47:05 -0400
In-Reply-To: <1462723814-14732-1-git-send-email-kjlu@gatech.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kangjie Lu <kangjielu@gmail.com>
Date: Sun,  8 May 2016 12:10:14 -0400

> Stack object "dte_facilities" is allocated in x25_rx_call_request(),
> which is supposed to be initialized in x25_negotiate_facilities.
> However, 5 fields (8 bytes in total) are not initialized. This
> object is then copied to userland via copy_to_user, thus infoleak
> occurs.
> 
> Signed-off-by: Kangjie Lu <kjlu@gatech.edu>

Applied and queued up for -stable thanks.

Please start formatting your Subject lines properly, I've been fixing
all of them up by hand.

You should specify a subsystem name prefix, then a ":" character, then
a space, then a description of your change.  For example, for this
patch an appropriate Subject would have been:

	[PATCH] x25: Fix a kernel infoleak in x25_negotiate_facilities().

Thanks.
