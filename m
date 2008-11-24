From: Patrick McHardy <kaber@trash.net>
Subject: Re: bridge: Fix update_pmtu crash with GRE
Date: Mon, 24 Nov 2008 13:35:46 +0100
Message-ID: <492A9FA2.1020809@trash.net>
References: <20081009070424.GA16684@gondor.apana.org.au> <E1KnpaS-0004Pe-Qt@gondolin.me.apana.org.au> <48EDC429.5090502@snapgear.com> <20081009103956.GA18751@gondor.apana.org.au> <20081124064957.GA15999@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Philip Craig <philipc@snapgear.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62316 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752340AbYKXMfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 07:35:55 -0500
In-Reply-To: <20081124064957.GA15999@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Looks like this fell through the cracks:
> 
> bridge: Fix update_pmtu crash with GRE
> 
> As GRE tries to call the update_pmtu function on skb->dst and
> bridge supplies an skb->dst that has a NULL ops field, all is
> not well.
> 
> This patch fixes this by giving the bridge device an ops field
> with an update_pmtu function.  For the moment I've left all
> other fields blank but we can fill them in later should the
> need arise.
> 
> Based on report and patch by Philip Craig.

Applied, thanks Herbert.

