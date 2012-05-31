From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] bql: Avoid possible inconsistent calculation.
Date: Thu, 31 May 2012 18:20:08 -0400 (EDT)
Message-ID: <20120531.182008.717292659289989881.davem@davemloft.net>
References: <20120531072537.920f0cb0.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com, denys@visp.net.lb,
	netdev@vger.kernel.org
To: shimoda.hiroaki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757647Ab2EaWUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 18:20:12 -0400
In-Reply-To: <20120531072537.920f0cb0.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Date: Thu, 31 May 2012 07:25:37 +0900

> dql->num_queued could change while processing dql_completed().
> To provide consistent calculation, added an on stack variable.
> 
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>

Applied and queued up for -stable.
