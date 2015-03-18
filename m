From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v2 PATCH 0/6] rhashtable: Kill redundant shift parameter
Date: Wed, 18 Mar 2015 10:57:47 +0000
Message-ID: <20150318105747.GI11089@casper.infradead.org>
References: <20150318090030.GA22108@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53953 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755471AbbCRK5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 06:57:49 -0400
Content-Disposition: inline
In-Reply-To: <20150318090030.GA22108@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/18/15 at 08:00pm, Herbert Xu wrote:
> Hi Dave:
> 
> I was trying to squeeze bucket_table->rehash in by downsizing
> bucket_table->size, only to find that my spot had been taken
> over by bucket_table->shift.  These patches kill shift and makes
> me feel better :)
> 
> v2 corrects the typo in the test_rhashtable changelog and also
> notes the min_shift parameter in the tipc patch changelog.

Series looks great.

Acked-by: Thomas Graf <tgraf@suug.ch>
