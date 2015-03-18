From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH 0/6] rhashtable: Kill redundant shift parameter
Date: Wed, 18 Mar 2015 20:00:30 +1100
Message-ID: <20150318090030.GA22108@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:47027 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074AbbCRJAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 05:00:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

I was trying to squeeze bucket_table->rehash in by downsizing
bucket_table->size, only to find that my spot had been taken
over by bucket_table->shift.  These patches kill shift and makes
me feel better :)

v2 corrects the typo in the test_rhashtable changelog and also
notes the min_shift parameter in the tipc patch changelog.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
