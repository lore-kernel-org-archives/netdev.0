From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH ipsec] xfrm: prevent ipcomp scratch buffer race condition
Date: Thu, 17 Oct 2013 15:13:26 +0200
Message-ID: <20131017131326.GB6747@unicorn.suse.cz>
References: <20131014160334.BCCDDE8A31@unicorn.suse.cz>
 <20131016123205.GA9982@gondor.apana.org.au>
 <20131017110149.GA6747@unicorn.suse.cz>
 <20131017110420.GA21027@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58465 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755571Ab3JQNN1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Oct 2013 09:13:27 -0400
Content-Disposition: inline
In-Reply-To: <20131017110420.GA21027@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 17, 2013 at 07:04:20PM +0800, Herbert Xu wrote:
V> On Thu, Oct 17, 2013 at 01:01:49PM +0200, Michal Kubecek wrote:
> > 
> > Am I wrong?
> 
> I hope so :) Because otherwise xfrm_input will surely dead-lock since
> it uses spin_lock.
> 
> The cases you mentioned should all go through netif_rx which will
> then do the processing in BH context.

You are right. Thank you for the correction.

Michal Kubecek
