From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Wrong UIDs reported in /proc/net/tcp
Date: Wed, 10 Nov 2004 09:58:12 +1100
Message-ID: <20041109225812.GA6001@gondor.apana.org.au>
References: <20041109205358.GA64015@calma.pair.com> <E1CRdBr-0001P2-00@gondolin.me.apana.org.au> <20041109224337.GB87321@calma.pair.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "Chad N. Tindel" <chad@tindel.net>
Content-Disposition: inline
In-Reply-To: <20041109224337.GB87321@calma.pair.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 09, 2004 at 05:43:37PM -0500, Chad N. Tindel wrote:
>
> > /proc/net/tcp is an obsolete interface.  It is inherently unreliable
> > in that a record may be read using two read(2) calls.  Those two calls
> > may end up looking at two different records.
> 
> Is it unreliable in that the wrong user id will get returned for an 
> established socket?  How could such a thing happen?

In 2.4 it is entirely possible to have a record broken up into two
reads.  There is no guarantee that the two reads will be reading the
same record.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
