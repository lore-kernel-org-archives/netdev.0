From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] be2net: fix be_close() to ensure all events are
 ack'ed
Date: Tue, 18 Dec 2012 16:19:01 -0800 (PST)
Message-ID: <20121218.161901.15020148690947523.davem@davemloft.net>
References: <f1923deb-9df8-4c1e-97be-944fd119e2ce@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754982Ab2LSATE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 19:19:04 -0500
In-Reply-To: <f1923deb-9df8-4c1e-97be-944fd119e2ce@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Tue, 18 Dec 2012 11:08:50 +0530

> In be_close(), be_eq_clean() must be called after all RX/TX/MCC queues
> have been cleaned to ensure that any events caused while cleaning up
> completions are notified/acked. Not clearing all events can cause
> upredictable behaviour when RX rings are re-created in the subsequent
> be_open().
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
