From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] rxrpc: Fix error handling in af_rxrpc_init()
Date: Tue, 12 Jul 2016 11:08:13 -0700 (PDT)
Message-ID: <20160712.110813.1349096182644249319.davem@davemloft.net>
References: <1468322477-32616-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, yongjun_wei@trendmicro.com.cn,
	linux-afs@lists.infradead.org, netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46620 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbcGLSIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 14:08:14 -0400
In-Reply-To: <1468322477-32616-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Tue, 12 Jul 2016 11:21:17 +0000

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> security initialized after alloc workqueue, so we should exit security
> before destroy workqueue in the error handing.
> 
> Fixes: 648af7fca159 ("rxrpc: Absorb the rxkad security module")
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
