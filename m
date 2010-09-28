From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Tue, 28 Sep 2010 07:12:58 +0200
Message-ID: <20100928051258.GB12373@1wt.eu>
References: <20100927192112.GT12373@1wt.eu> <20100927232857.GA23803@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:45743 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754491Ab0I1FNH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 01:13:07 -0400
Content-Disposition: inline
In-Reply-To: <20100927232857.GA23803@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 28, 2010 at 08:28:57AM +0900, Herbert Xu wrote:
> Willy Tarreau <w@1wt.eu> wrote:
> > 
> > Two quick facts :
> >  - HTTP allows the client to send whatever it wants whenever it wants
> >    and allows the server to close after whatever response it wants.
> >    Thus the server cannot predict that the client will talk.
> 
> No it does not.  Only buggy HTTP clients do that.

I don't agree Herbert. Pipelining consists exactly in that, and is an
encouraged practice. If you say that only buggy clients send an extra
CRLF, then yes I agree. But you might very well get a new request you
can't predict at all, and the arrival of this new request must not 
destroy the end of last response's data.

Once again, for now, I will only handle this precise case of the extra
CRLF, but this will not fix the issue with pipelined requests.

Regards,
Willy

