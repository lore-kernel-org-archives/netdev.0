From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Tue, 28 Jul 2009 19:48:03 +0800
Message-ID: <20090728114803.GA28001@gondor.apana.org.au>
References: <20090728024813.GA23992@gondor.apana.org.au> <20090727.212107.161491585.davem@davemloft.net> <20090728064319.GA5424@ff.dom.local> <20090728080354.GA25953@gondor.apana.org.au> <20090728083713.GB5424@ff.dom.local> <20090728084451.GA26299@gondor.apana.org.au> <20090728090229.GA6593@ff.dom.local> <20090728105329.GA27453@gondor.apana.org.au> <20090728112445.GB6593@ff.dom.local> <OFD1BE2D07.6BDFA87B-ON65257601.003F8F24-65257601.00406E62@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53084 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751320AbZG1LsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 07:48:12 -0400
Content-Disposition: inline
In-Reply-To: <OFD1BE2D07.6BDFA87B-ON65257601.003F8F24-65257601.00406E62@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 28, 2009 at 05:13:45PM +0530, Krishna Kumar2 wrote:
> Sure, I will test and give my findings here. I guess setting the
> flag in qdisc_create_dflt is the right place - that will cover pfifo,
> bfifo and pfifo_fast (instead of attach_one_default_qdisc)?

No I think you want to put it in attach_one_default_qdisc.

Despite its name, qdisc_create_dflt is used by non-default qdiscs
too.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
