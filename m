From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fixup for tracepoint napi:napi_poll
Date: Fri, 15 Jul 2016 15:55:19 -0700 (PDT)
Message-ID: <20160715.155519.119451962801516100.davem@davemloft.net>
References: <20160715215520.13891.51701.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rostedt@goodmis.org
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55862 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbcGOWzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 18:55:23 -0400
In-Reply-To: <20160715215520.13891.51701.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Fri, 15 Jul 2016 23:55:20 +0200

> The recent change to tracepoint napi:napi_poll changed the order of
> the parameters that perf scripts sees, the printk was correct.  The
> problem was that the new parameters (work and budget) were pushed
> in front of dev_name.
> 
> The new parameters obviously need to be appended to keep backward
> compatible.
> 
> Fixes: 1db19db7f5ff ("net: tracepoint napi:napi_poll add work and budget")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied, thanks Jesper.
