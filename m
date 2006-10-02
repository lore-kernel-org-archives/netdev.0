From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] Revert [NET_SCHED]: HTB: fix incorrect use of RB_EMPTY_NODE
Date: Mon, 2 Oct 2006 13:52:53 +0200
Message-ID: <20061002115253.GA3707@ff.dom.local>
References: <200609302223.47627.ismail@pardus.org.tr> <20061002102447.GA2936@ff.dom.local> <20061002111555.GB2936@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.go2.pl ([193.17.41.41]:9154 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1750953AbWJBLsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 07:48:25 -0400
To: Ismail Donmez <ismail@pardus.org.tr>, axboe@suse.de,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20061002111555.GB2936@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 02, 2006 at 01:15:55PM +0200, Jarek Poplawski wrote:
...
> instead of:
> 
> + if (RB_EMPTY_NODE(rb))

should be:

+ if (RB_EMPTY_NODE(node))

Jarek P.
