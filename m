From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PANIC] lro + iscsi or lro + skb text search causes panic
Date: Tue, 27 Jan 2009 14:01:56 +1100
Message-ID: <20090127030156.GA26604@gondor.apana.org.au>
References: <alpine.WNT.2.00.0901221234420.4188@jbrandeb-desk1.amr.corp.intel.com> <20090122232131.GA22771@gondor.apana.org.au> <4979097B.4040108@cs.wisc.edu> <20090125.213222.192571170.davem@davemloft.net> <20090126223022.GA24046@gondor.apana.org.au> <F169D4F5E1F1974DBFAFABF47F60C10A1C225135@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"michaelc@cs.wisc.edu" <michaelc@cs.wisc.edu>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@suug.ch" <tgraf@suug.ch>, "kkeil@suse.de" <kkeil@suse.de>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44800 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752883AbZA0DCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 22:02:06 -0500
Content-Disposition: inline
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A1C225135@orsmsx507.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 26, 2009 at 05:40:08PM -0800, Brandeburg, Jesse wrote:
>
> 1-3 (both, :-)) doesn't seem to work here, I applied this and still got a 
> panic when doing a quick test before I went home today.
> 
> I can get panic trace from netconsole tomorrow.

OK, looking at the original trace it looks like none of the bugs
I've fixed actually explain it.  The crash looks more like a ref
count bug, which means that the issue isn't so much about the
skb_seq_read interface (which should be fixed in any case), but
in the iSCSI code itself.

More digging is required.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
