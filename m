From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Revert [NET_SCHED]: HTB: fix incorrect use of RB_EMPTY_NODE
Date: Tue, 03 Oct 2006 20:05:33 +0200
Message-ID: <4522A66D.3020702@trash.net>
References: <200609302223.47627.ismail@pardus.org.tr> <20061002111555.GB2936@ff.dom.local> <20061003102831.GA7778@kernel.dk> <200610031554.56353.ismail@pardus.org.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <jens.axboe@oracle.com>,
	Jarek Poplawski <jarkao2@o2.pl>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:29841 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1030344AbWJCSEX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 14:04:23 -0400
To: Ismail Donmez <ismail@pardus.org.tr>
In-Reply-To: <200610031554.56353.ismail@pardus.org.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ismail Donmez wrote:
> With commit 10fd48f2376db52f08bf0420d2c4f580e39269e1 [1] ,  RB_EMPTY_NODE 
> changed behaviour so it returns true when the node is empty as expected. 
> Hence Patrick McHardy's fix for sched_htb.c should be reverted.
> 
> Signed-off-by: Ismail Donmez <ismail@pardus.org.tr>

ACKed-by: Patrick McHardy <kaber@trash.net>
