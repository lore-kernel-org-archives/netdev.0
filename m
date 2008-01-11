From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Fri, 11 Jan 2008 15:55:01 +1100
Message-ID: <E1JDBv3-0006J9-00@gondolin.me.apana.org.au>
References: <23761.1200013613@death>
Cc: herbert@gondor.apana.org.au, andy@greyhouse.net, olel@ans.pl,
	netdev@vger.kernel.org, jgarzik@pobox.com, davem@davemloft.net
To: fubar@us.ibm.com (Jay Vosburgh)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2154 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757604AbYAKEzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 23:55:35 -0500
In-Reply-To: <23761.1200013613@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh <fubar@us.ibm.com> wrote:
>
>        For the case of the bond_set_multicast_list function, changing
> the existing write_lock to a read_lock_bh doesn't affect any calls to

Right that should also resolve the lockdep issue.  So as long as you
guys are sure that this is safe with respect to the rest of the bonding
driver it's fine by me.

BTW you only need read_lock since set_multicast_list always gets called
with BH off.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
