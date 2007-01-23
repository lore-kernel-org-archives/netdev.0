From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: why would EPIPE cause socket port to change?
Date: Tue, 23 Jan 2007 14:15:45 +0300
Message-ID: <45B5EE61.7010507@tls.msk.ru>
References: <E1H9ES2-0006uJ-00@gondolin.me.apana.org.au> <45B5ED2F.7020303@tls.msk.ru> <20070123111225.GA29349@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dean gaudet <dean@arctic.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:22491 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932255AbXAWLPu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 06:15:50 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20070123111225.GA29349@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Tue, Jan 23, 2007 at 02:10:39PM +0300, Michael Tokarev wrote:
>> Well, but why getsockname() didn't just return ENOTCONN?
> 
> It's perfectly valid to have a local port number without being connected.

Er.  You're right - I was confusing getSOCKname() and getPEERname().

Still, after the connection has been closed, there's no chance to do
anything with the filedescriptor but to close it as well, right?  Or
can the fd be reused by making new connection with it, as if it were
just returned from socket() call?

If it's the former, than there's no reason to assign new local address
to it.

/mjt
