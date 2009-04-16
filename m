From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun: performance regression in 2.6.30-rc1
Date: Fri, 17 Apr 2009 07:57:53 +0800
Message-ID: <20090416235753.GA30165@gondor.apana.org.au>
References: <20090416213122.GB5894@dhcp-1-124.tlv.redhat.com> <20090416221505.GA5937@dhcp-1-124.tlv.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Max Krasnyansky <maxk@qualcomm.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "Michael S. Tsirkin" <m.s.tsirkin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38954 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755906AbZDPX6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 19:58:01 -0400
Content-Disposition: inline
In-Reply-To: <20090416221505.GA5937@dhcp-1-124.tlv.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2009 at 01:15:05AM +0300, Michael S. Tsirkin wrote:
>
> Continuing with the investigation, commenting out
> atomic_inc_not_zero and atomic_dec_and_test in tun_get/tun_put
> gets us back most of the rest of the performance:

I'll try to think of a way to kill these ref counts, once I get
my other patch fixed :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
