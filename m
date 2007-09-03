From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: some weird corruption in net-2.6.24
Date: Tue, 04 Sep 2007 07:05:36 +0800
Message-ID: <E1ISKzA-0007xM-00@gondolin.me.apana.org.au>
References: <20070903095719.GE18480@postel.suug.ch>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: tgraf@suug.ch (Thomas Graf)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2696 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751131AbXICXGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2007 19:06:00 -0400
In-Reply-To: <20070903095719.GE18480@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf <tgraf@suug.ch> wrote:
> 
> I've been trying to reproduce this, what happens on my system
> is that when the ISAKMP SA lifetime is exceeded the rekeying
> fails and my connection dies. I can reproduce this back to
> 2.6.22 and it doesn't seem related to my recent xfrm_user work.
> It looks like this behaviour is hiding the bug you are seeing.

Could you try extending the ISAKMP SA life time so that it is
longer than the IPSec SA life time?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
