From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] netlink: Mark dumps as inconsistent which have been
 interrupted by a resize
Date: Thu, 22 Jan 2015 19:49:24 +1100
Message-ID: <20150122084924.GA4720@gondor.apana.org.au>
References: <cover.1421759056.git.tgraf@suug.ch>
 <cce004895ab6bcef267e2133a1c7ecab0fac403b.1421759056.git.tgraf@suug.ch>
 <54BF5FC4.4070808@windriver.com>
 <20150121121748.GD12570@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ying Xue <ying.xue@windriver.com>, davem@davemloft.net,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:51322 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493AbbAVItu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 03:49:50 -0500
Content-Disposition: inline
In-Reply-To: <20150121121748.GD12570@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 21, 2015 at 12:17:48PM +0000, Thomas Graf wrote:
>
> Thanks for the review. We also need to avoid hitting 0 when we overflow
> on a seq increment.  The netfilter code is doing this correctly but several
> other users are suffering from this as well.
> 
> I'll address this in v2 together with the other discussed changes.

Could you hold off for a bit? I've got some changes that touch
this area that I'd like to push out.  Basically I'm trying to
eliminate direct access of rhashtable internals from the existing
users.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
