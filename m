From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH 0/9]: TCP: The Road to Super TSO
Date: Wed, 8 Jun 2005 17:40:10 -0400
Message-ID: <200506081740.11292.jheffner@psc.edu>
References: <20050606.210846.07641049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050606.210846.07641049.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 07 June 2005 12:08 am, David S. Miller wrote:
> Some folks, notable the S2IO guys, get performance degradation
> from the Super TSO v2 patch (they get it from the first version
> as well).  It's a real pain to spot what causes such things
> in such a huge patch... so I started splitting things up in
> a very fine grained manner so we can catch regressions more
> precisely.

I'm curious about the details of this.  Is there decreased performance 
relative to current TSO?  Relative to no TSO?  Sending to just one receiver 
or many, and is it receiver limited?

  -John
