From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: linux-next: build warnings after merge of the crypto tree
Date: Wed, 11 Mar 2015 13:05:56 +1100
Message-ID: <20150311020556.GA1260@gondor.apana.org.au>
References: <20150310164417.540c18a4@canb.auug.org.au>
 <20150310060328.GA14997@gondor.apana.org.au>
 <54FFA1BA.30009@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stephan Mueller <smueller@chronox.de>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
To: Tadeusz Struk <tadeusz.struk@intel.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54FFA1BA.30009@intel.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 10, 2015 at 07:00:26PM -0700, Tadeusz Struk wrote:
> On 03/09/2015 11:03 PM, Herbert Xu wrote:
> > This is a bit of a bummer.  What happened is that net-next has
> > killed the kiocb argument to sendmsg/recvmsg.  However, this
> > change is obviously not part of the crypto tree and algif_aead
> > only exists in the crypto tree.
> > 
> > So Stephen could you fix this by hand until one of them is merged
> > upstream (just kill the first argument in aead_sendmsg/aead_recvmsg)?
> 
> So does it mean that aio operations will not be supported on sockets?

Indeed.  If you want to have this ability you'll need to take
the discussion over to netdev.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
