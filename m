From: "Chad N. Tindel" <chad@tindel.net>
Subject: Re: Wrong UIDs reported in /proc/net/tcp
Date: Tue, 9 Nov 2004 17:43:37 -0500
Message-ID: <20041109224337.GB87321@calma.pair.com>
References: <20041109205358.GA64015@calma.pair.com> <E1CRdBr-0001P2-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1CRdBr-0001P2-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > In our testing we've found some occurrences of identd reporting back the
> > wrong username for the owner of a socket.  We added some instrumentation
> 
> /proc/net/tcp is an obsolete interface.  It is inherently unreliable
> in that a record may be read using two read(2) calls.  Those two calls
> may end up looking at two different records.

Is it unreliable in that the wrong user id will get returned for an 
established socket?  How could such a thing happen?

Chad
