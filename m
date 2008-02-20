From: David Miller <davem@davemloft.net>
Subject: Re: [RFC: 2.6.25 patch] ipv4/fib_hash.c: fix NULL dereference
Date: Tue, 19 Feb 2008 16:29:14 -0800 (PST)
Message-ID: <20080219.162914.197514826.davem@davemloft.net>
References: <20080219224951.GP31955@cs181133002.pp.htv.fi>
	<47BB60E6.6030506@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bunk@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57913
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756683AbYBTA2h convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 19:28:37 -0500
In-Reply-To: <47BB60E6.6030506@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 20 Feb 2008 00:06:14 +0100

> Adrian Bunk a =E9crit :
> > Unless I miss a guaranteed relation between between "f" and=20
> > "new_fa->fa_info" this patch is required for fixing a NULL derefere=
nce
> > introduced by commit a6501e080c318f8d4467679d17807f42b3a33cd5 and=20
> > spotted by the Coverity checker.
> >=20
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
 ...
> Hum, you are right, kmem_cache_free() doesnt allow a NULL object, lik=
e kfree()=20
> does.

Applied, thanks everyone.
