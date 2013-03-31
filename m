From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] [RFC] [v2] net: add option to enable error
 queue packets waking select
Date: Sun, 31 Mar 2013 19:45:22 -0400 (EDT)
Message-ID: <20130331.194522.608435617919159346.davem@davemloft.net>
References: <20130328211925.7644.15781.stgit@jekeller-hub.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	richardcochran@gmail.com, matthew.vick@intel.com
To: jacob.e.keller@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49911 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756374Ab3CaXpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Mar 2013 19:45:24 -0400
In-Reply-To: <20130328211925.7644.15781.stgit@jekeller-hub.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>
Date: Thu, 28 Mar 2013 14:19:25 -0700

> Currently, when a socket receives something on the error queue it only wakes up
> the socket on select if it is in the "read" list, that is the socket has
> something to read. It is useful also to wake the socket if it is in the error
> list, which would enable software to wait on error queue packets without waking
> up for regular data on the socket. The main use case is for receiving
> timestamped transmit packets which return the timestamp to the socket via the
> error queue. This enables an application to select on the socket for the error
> queue only instead of for the regular traffic.
> 
> -v2-
> * Added the SO_SELECT_ERR_QUEUE socket option to every architechture specific file
> * Modified every socket poll function that checks error queue
> 
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>

Applied, thanks.
