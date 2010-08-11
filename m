From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netpoll: use non-BH variant of RCU
Date: Wed, 11 Aug 2010 07:03:30 -0400
Message-ID: <20100811110330.GA6440@gondor.apana.org.au>
References: <1281471924-2237-1-git-send-email-linville@tuxdriver.com> <20100810204358.GA1076@gondor.apana.org.au> <20100810211932.GG2379@linux.vnet.ibm.com> <20100810.163117.241919476.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com, linville@tuxdriver.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:37681 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426Ab0HKLDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 07:03:44 -0400
Content-Disposition: inline
In-Reply-To: <20100810.163117.241919476.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 10, 2010 at 04:31:17PM -0700, David Miller wrote:
>
> Linus's tree is fine for this.
> 
> But we need this fix for 2.6.35-stable too.  Herbert would
> you object to putting John's more simple fix there?

To use rcu_read_lock safely we'd also need to add do synchronize_rcu
in addition of synchronize_rcu_bh, right Paul?

Of course as we were doing this unsafely prior to my patch anyway
I'm also fine with just reverting it.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
