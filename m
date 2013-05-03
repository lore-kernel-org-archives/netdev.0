From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: fix race with topology change timer
Date: Fri, 03 May 2013 16:11:37 -0400 (EDT)
Message-ID: <20130503.161137.1979947914410869390.davem@davemloft.net>
References: <20130502172328.2ff0273f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48125 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934198Ab3ECULl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 16:11:41 -0400
In-Reply-To: <20130502172328.2ff0273f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 2 May 2013 17:23:28 -0700

> A bridge should only send topology change notice if it is not
> the root bridge. It is possible for message age timer to elect itself
> as a new root bridge, and still have a topology change timer running
> but waiting for bridge lock on other CPU.
> 
> Solve the race by checking if we are root bridge before continuing.
> This was the root cause of the cases where br_send_tcn_bpdu would OOPS.
> 
> Reported-by: JerryKang <jerry.kang@samsung.com>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied and queued up for -stable.
