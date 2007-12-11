From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [NET]: Fix Ooops of napi net_rx_action.
Date: Tue, 11 Dec 2007 20:36:21 +0800
Message-ID: <E1J24LV-0003ig-00@gondolin.me.apana.org.au>
References: <20071211.023218.31965443.davem@davemloft.net>
Cc: joonwpark81@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3073 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751387AbXLKMg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 07:36:28 -0500
In-Reply-To: <20071211.023218.31965443.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> How can the NAPI_STATE_SCHED bit be cleared externally yet we take
> this list_move_tail() code path?

His driver is probably buggy.  When we had two drivers beginning
with e100 we often forgot to apply fixes to the both of them.  Now
that we have three it's even more confusing.

I just checked and indeed e1000e seems to be missing the NAPI fix
that was applied to e1000.  Of course it doesn't rule out the
possibility of another NAPI bug in e1000.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
