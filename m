From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 3/3] [UDP6]: Counter increment on BH mode
Date: Mon, 3 Dec 2007 14:49:12 +0300
Message-ID: <20071203114912.GA4425@ms2.inr.ac.ru>
References: <474F7EE8.2040009@cn.fujitsu.com> <474F8255.5060501@cn.fujitsu.com> <20071130111949.GB28277@gerrit.erg.abdn.ac.uk> <20071201015438.GC26895@gondor.apana.org.au> <4753AE07.1040906@cn.fujitsu.com> <20071203113935.GA25124@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Chen <wangchen@cn.fujitsu.com>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>, davem@davemloft.net,
	andi@firstfloor.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:41101 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753282AbXLCLtw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 06:49:52 -0500
Content-Disposition: inline
In-Reply-To: <20071203113935.GA25124@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 03, 2007 at 10:39:35PM +1100, Herbert Xu wrote:
> So we need to fix this, and whatever the fix is will probably render
> the BH/USER distinction obsolete.

Hmm, I would think opposite. USER (or generic) is expensive variant,
BH is lite. No?

Alexey
