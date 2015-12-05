From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Sat, 5 Dec 2015 09:08:19 +0800
Message-ID: <20151205010819.GA21889@gondor.apana.org.au>
References: <564DB5F5.9060208@profihost.ag>
 <1447936902.1986892.444251921.3928A049@webmail.messagingengine.com>
 <564DC4A5.70104@profihost.ag>
 <564DCC4C.1090009@redhat.com>
 <564E2852.8000200@profihost.ag>
 <56530A42.6030609@profihost.ag>
 <1448283451.4019628.447573353.3659E447@webmail.messagingengine.com>
 <565EBDC1.1090808@profihost.ag>
 <8737vlt6xb.fsf@stressinduktion.org>
 <5661DAC4.8040909@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Weimer <fweimer@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stefan Priebe <s.priebe@profihost.ag>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5661DAC4.8040909@profihost.ag>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 04, 2015 at 07:26:12PM +0100, Stefan Priebe wrote:
>
> * 9f87e0c - (2 months ago) netlink: Replace rhash_portid with bound
> - Herbert Xu
> * 35e9890 - (3 months ago) netlink: Fix autobind race condition that
> leads to zero port ID - Herbert Xu
> * 30c6472 - (7 months ago) netlink: Use random autobind rover - Herbert Xu

These three patches are absolutely required in any kernel where the
netlink insertion is lockless.  So yes they should be applied to
4.1.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
