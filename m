From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: net: Fix skb csum races when peeking
Date: Mon, 13 Jul 2015 22:25:45 +0800
Message-ID: <20150713142545.GA12428@gondor.apana.org.au>
References: <20150710115141.12980.88829.stgit@buzz>
 <20150713072352.GA8485@gondor.apana.org.au>
 <1436774742.9402.3.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150713081040.GB8971@gondor.apana.org.au>
 <1436775754.9402.6.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150713082544.GA9176@gondor.apana.org.au>
 <CANn89iLFCJWqmfvwOUB_7VUk_7jHHvOHZR6=fufDr848thSrHQ@mail.gmail.com>
 <20150713083100.GA9263@gondor.apana.org.au>
 <20150713120142.GA9787@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:56729 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292AbbGMOZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 10:25:56 -0400
Content-Disposition: inline
In-Reply-To: <20150713120142.GA9787@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 13, 2015 at 08:01:42PM +0800, Herbert Xu wrote:
> 
> PS we seem to no longer use the hardware checksum in case of
> CHECKSUM_COMPLETE, I wonder why that is?

Nevermind, it's still there.  I was just looking in the wrong place.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
