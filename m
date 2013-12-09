From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] net-gro: Prepare GRO stack for the upcoming
 tunneling support
Date: Mon, 9 Dec 2013 11:16:08 +0800
Message-ID: <20131209031608.GA30758@gondor.apana.org.au>
References: <1386518682-30488-1-git-send-email-hkchu@google.com>
 <1386531839.30495.296.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAPshTCiv1HxL9pRg3vp7pAOtdOOKoMVRQ4w8acq3aMga07NRig@mail.gmail.com>
 <1386558263.30495.311.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131209030830.GA30565@gondor.apana.org.au>
 <1386558820.30495.313.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jerry Chu <hkchu@google.com>, Eric Dumazet <edumazet@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:50002 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760364Ab3LIDQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 22:16:16 -0500
Content-Disposition: inline
In-Reply-To: <1386558820.30495.313.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 08, 2013 at 07:13:40PM -0800, Eric Dumazet wrote:
>
> Thats not what I said.
> 
> Please read 1def9238d4aa2146924994aa4b7dc861f03b9362 changelog
> for details.
> 
> If GRO is off, of course qdisc_pkt_len_init() has no problem.

Fair enough.  For GSO packets yes transport_header is required.
It's been this way from the very start since we need it for
checksums too.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
