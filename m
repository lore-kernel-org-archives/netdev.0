From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH -next] rxrpc: Fix error handling in af_rxrpc_init()
Date: Thu, 14 Jul 2016 15:19:40 +0100
Message-ID: <16935.1468505980@warthog.procyon.org.uk>
References: <20160712.110813.1349096182644249319.davem@davemloft.net> <1468322477-32616-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, weiyj_lk@163.com, netdev@vger.kernel.org,
	yongjun_wei@trendmicro.com.cn, linux-afs@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37685 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751051AbcGNOTp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 10:19:45 -0400
In-Reply-To: <20160712.110813.1349096182644249319.davem@davemloft.net>
Content-ID: <16934.1468505980.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

> > From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> > 
> > security initialized after alloc workqueue, so we should exit security
> > before destroy workqueue in the error handing.
> > 
> > Fixes: 648af7fca159 ("rxrpc: Absorb the rxkad security module")
> > Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Applied.

Thanks.

David
