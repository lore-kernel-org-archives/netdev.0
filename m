From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dql: Fix inconsistency between file mode and attr
 method.
Date: Tue, 17 Jan 2012 10:06:15 -0500 (EST)
Message-ID: <20120117.100615.357923937750093470.davem@davemloft.net>
References: <20120115021021.1bb055da.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: shimoda.hiroaki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54422 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753763Ab2AQPGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 10:06:20 -0500
In-Reply-To: <20120115021021.1bb055da.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Date: Sun, 15 Jan 2012 02:10:21 +0900

> There is no store() method for inflight attribute in the
> tx-<n>/byte_queue_limits sysfs directory.
> So remove S_IWUSR bit.
> 
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>

Applied, with fixed subject line.  It's "bql" not "dql" :-)
