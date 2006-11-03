From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [take1] d80211: switch crypto to use new ciphers API
Date: Thu, 2 Nov 2006 21:10:27 -0500
Message-ID: <20061103021021.GC2989@tuxdriver.com>
References: <20061025224150.GA7364@devicescape.com> <20061026000624.GA29389@gondor.apana.org.au> <20061030180858.GA12593@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:13587 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1752955AbWKCCZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 21:25:08 -0500
To: David Kimdon <david.kimdon@devicescape.com>
Content-Disposition: inline
In-Reply-To: <20061030180858.GA12593@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 30, 2006 at 10:08:58AM -0800, David Kimdon wrote:
> On Thu, Oct 26, 2006 at 10:06:24AM +1000, Herbert Xu wrote:
> > If you're only encrypting/decrypting a single block then you should
> > use the cipher interface.  So net/d80211/aes_ccm.c should do that
> > instead.  See drivers/net/wirless/airo.c for an example of that.
> 
> Thanks Herbert.
> 
> Updated patch, now aes, tkip and wep are all tested.
> 
> Changes from take0:
> 
> Use IS_ERR() to evaluate return value of crypto_alloc_cipher().  Use
> ciper interface rather than blkcipher for aes encryption since we only
> encrypt a single block at a time.
> 
> --------
> 
> Switch d80211 software crypto to use the new cipher API.

Applied to wireless-dev.

-- 
John W. Linville
linville@tuxdriver.com
