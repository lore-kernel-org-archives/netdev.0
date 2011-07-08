From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3] sctp: ABORT if receive, reassmbly, or reodering
 queue is not empty while closing socket
Date: Fri, 08 Jul 2011 09:37:49 -0700 (PDT)
Message-ID: <20110708.093749.899388186927369532.davem@davemloft.net>
References: <20110708105705.GA14583@canuck.infradead.org>
	<4E170B00.9080406@hp.com>
	<20110708143746.GB24249@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, netdev@vger.kernel.org,
	yjwei@cn.fujitsu.com, sri@us.ibm.com, linux-sctp@vger.kernel.org
To: tgraf@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36505 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754318Ab1GHQjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 12:39:06 -0400
In-Reply-To: <20110708143746.GB24249@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@infradead.org>
Date: Fri, 8 Jul 2011 10:37:46 -0400

> Trigger user ABORT if application closes a socket which has data
> queued on the socket receive queue or chunks waiting on the
> reassembly or ordering queue as this would imply data being lost
> which defeats the point of a graceful shutdown.
> 
> This behavior is already practiced in TCP.
> 
> We do not check the input queue because that would mean to parse
> all chunks on it to look for unacknowledged data which seems too
> much of an effort. Control chunks or duplicated chunks may also
> be in the input queue and should not be stopping a graceful
> shutdown.
> 
> Signed-off-by: Thomas Graf <tgraf@infradead.org>

Vlad please ACK/NACK this updated patch.

Thanks.
