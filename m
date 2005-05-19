From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Thu, 19 May 2005 22:48:21 +1000
Message-ID: <20050519124821.GA686@gondor.apana.org.au>
References: <428B6B72.5010407@hp.com> <E1DYWM2-0004jM-00@gondolin.me.apana.org.au> <20050519122319.GH15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050519122319.GH15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 19, 2005 at 02:23:19PM +0200, Thomas Graf wrote:
> 
> I agree, however defining a value of 600 system wide is horrible for
> all hosts that behave "correctly". So what we could do is take probes
> of the id distribution and define the threshold on a per peer scope.
> 
> Example: Once in a while we start a probe and set a bit in a bitmap
> for every id that matches a defined window. Not sure about the size of
> that bitmap yet but 2048 bits might be a good start. The first fragment

Sorry, but this scheme is way too complex for a problem that only affects
a tiny section of the community.  If you really want to do this then
do it as a static route flag instead of something that the system tries
to auto-detect.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
