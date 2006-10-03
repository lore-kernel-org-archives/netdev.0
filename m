From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert [NET_SCHED]: HTB: fix incorrect use of
 RB_EMPTY_NODE
Date: Tue, 03 Oct 2006 13:49:31 -0700 (PDT)
Message-ID: <20061003.134931.112622834.davem@davemloft.net>
References: <20061003102831.GA7778@kernel.dk>
	<200610031554.56353.ismail@pardus.org.tr>
	<4522A66D.3020702@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ismail@pardus.org.tr, jens.axboe@oracle.com, jarkao2@o2.pl,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:17611
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030383AbWJCUt3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 16:49:29 -0400
To: kaber@trash.net
In-Reply-To: <4522A66D.3020702@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 03 Oct 2006 20:05:33 +0200

> Ismail Donmez wrote:
> > With commit 10fd48f2376db52f08bf0420d2c4f580e39269e1 [1] ,  RB_EMPTY_NODE 
> > changed behaviour so it returns true when the node is empty as expected. 
> > Hence Patrick McHardy's fix for sched_htb.c should be reverted.
> > 
> > Signed-off-by: Ismail Donmez <ismail@pardus.org.tr>
> 
> ACKed-by: Patrick McHardy <kaber@trash.net>

Applied, thanks everyone.
