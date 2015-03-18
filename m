From: David Miller <davem@davemloft.net>
Subject: Re: [v2 PATCH 0/6] rhashtable: Kill redundant shift parameter
Date: Wed, 18 Mar 2015 12:47:27 -0400 (EDT)
Message-ID: <20150318.124727.1903690096349156464.davem@davemloft.net>
References: <20150318090030.GA22108@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932844AbbCRQra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 12:47:30 -0400
In-Reply-To: <20150318090030.GA22108@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 18 Mar 2015 20:00:30 +1100

> I was trying to squeeze bucket_table->rehash in by downsizing
> bucket_table->size, only to find that my spot had been taken
> over by bucket_table->shift.  These patches kill shift and makes
> me feel better :)
> 
> v2 corrects the typo in the test_rhashtable changelog and also
> notes the min_shift parameter in the tipc patch changelog.

I guess once you get OCD with something, it stands no chance of
surviving :-)

Looks great, series applied, thanks!
