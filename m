From: David Miller <davem@davemloft.net>
Subject: Re: [SCTP]: Always linearise packet on input
Date: Sun, 29 Oct 2006 23:46:19 -0800 (PST)
Message-ID: <20061029.234619.112618588.davem@davemloft.net>
References: <20061030071128.GA15715@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18660
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161179AbWJ3HqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 02:46:13 -0500
To: herbert@gondor.apana.org.au
In-Reply-To: <20061030071128.GA15715@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 30 Oct 2006 18:11:28 +1100

> [SCTP]: Always linearise packet on input
 ...
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I'll apply this, thanks a lot.

> Sridhar, could you please organise an audit of SCTP to make sure
> that it deals with skb fragments (both pages and frag_list) in a
> safe manner? Basically before you do an skb_pull or access skb->data
> you must ensure that the data you want to access is in the head,
> usually by doing skb_may_pull.  Of course, for large payloads it
> helps if you can avoid pulling it into the head.

Of course, you mean "pskb_may_pull" here.
:-)
