From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 1/2] Crypto support aesni rfc5288
Date: Tue, 24 Nov 2015 18:30:33 +0800
Message-ID: <20151124103033.GA623@gondor.apana.org.au>
References: <cover.1448299690.git.davejwatson@fb.com>
 <ca4759f2bfc18d1e4e56b514bba549fd1355d17b.1448299690.git.davejwatson@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org,
	davem@davemloft.net,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ca4759f2bfc18d1e4e56b514bba549fd1355d17b.1448299690.git.davejwatson@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 23, 2015 at 09:42:44AM -0800, Dave Watson wrote:
> Support rfc5288 using intel aesni routines.  See also rfc5246.
> 
> AAD length is 13 bytes padded out to 16. Padding bytes have to be
> passed in in scatterlist currently, which probably isn't quite the
> right fix.
> 
> The assoclen checks were moved to the individual rfc stubs, and the
> common routines support all assoc lengths.

I know this is just an RFC.  But if we were going to add an rfc5288
template then you should add a C version first, then followed by the
aesni optimised version.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
