From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: Re: linux-next: build warnings after merge of the crypto tree
Date: Tue, 10 Mar 2015 19:00:26 -0700
Message-ID: <54FFA1BA.30009@intel.com>
References: <20150310164417.540c18a4@canb.auug.org.au> <20150310060328.GA14997@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stephan Mueller <smueller@chronox.de>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150310060328.GA14997@gondor.apana.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/09/2015 11:03 PM, Herbert Xu wrote:
> This is a bit of a bummer.  What happened is that net-next has
> killed the kiocb argument to sendmsg/recvmsg.  However, this
> change is obviously not part of the crypto tree and algif_aead
> only exists in the crypto tree.
> 
> So Stephen could you fix this by hand until one of them is merged
> upstream (just kill the first argument in aead_sendmsg/aead_recvmsg)?

So does it mean that aio operations will not be supported on sockets?
