From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V2] net: tracepoint napi:napi_poll add work
 and budget
Date: Sat, 09 Jul 2016 18:05:28 -0400 (EDT)
Message-ID: <20160709.180528.1109686708875619397.davem@davemloft.net>
References: <20160707160118.32320.81577.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rostedt@goodmis.org
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38498 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752996AbcGIWFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 18:05:30 -0400
In-Reply-To: <20160707160118.32320.81577.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 07 Jul 2016 18:01:32 +0200

> An important information for the napi_poll tracepoint is knowing
> the work done (packets processed) by the napi_poll() call. Add
> both the work done and budget, as they are related.
> 
> Handle trace_napi_poll() param change in dropwatch/drop_monitor
> and in python perf script netdev-times.py in backward compat way,
> as python fortunately supports optional parameter handling.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied, thanks.
