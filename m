From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH 0/3] crypto: af_alg - add TLS type encryption
Date: Thu, 7 Apr 2016 23:58:50 -0300
Message-ID: <CALx6S37m_ayZJ4nth0SPNr2Km2+uBZUCtK4iqPKHTARv2eB4aA@mail.gmail.com>
References: <20160306012044.6369.63924.stgit@tstruk-mobl1>
	<20160405112940.GB11852@gondor.apana.org.au>
	<57054DBC.8010507@intel.com>
	<20160408025250.GA7596@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tadeusz Struk <tadeusz.struk@intel.com>,
	linux-crypto@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	davejwatson@fb.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160408025250.GA7596@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 7, 2016 at 11:52 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Wed, Apr 06, 2016 at 10:56:12AM -0700, Tadeusz Struk wrote:
>>
>> The intend is to enable HW acceleration of the TLS protocol.
>> The way it will work is that the user space will send a packet of data
>> via AF_ALG and HW will authenticate and encrypt it in one go.
>
> There have been suggestions to implement TLS data-path within
> the kernel.  So we should decide whether we pursue that or go
> with your approach before we start adding algorithms.
>
Yes, please see Dave Watson's patches on this.

Tom

> Cheers,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
