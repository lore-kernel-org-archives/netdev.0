From: Mika Liljeberg <mika.liljeberg@welho.com>
Subject: Re: Anycast usage, final diagnosis? (was: IPv6: Fix broken anycast
Date: 17 Jul 2003 12:32:33 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1058434352.5780.44.camel@hades>
References: <200307170906.NAA13688@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, jmorris@redhat.com, pekkas@netcore.fi,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307170906.NAA13688@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-07-17 at 12:06, kuznet@ms2.inr.ac.ru wrote:
> They cannot intersect, otherwise RTF_LOCAL thing will not work.
> 
> I deliberately blocked attempt to add a local address as anycast
> in anycast.c, see another chunk.

Ok, I missed that one.

I guess it's safe to assume that the anycast and unicast spaces will not
intersect, even though the addresses are allocated from the same range.
I was wondering how to dynamically assign anycast addresses. In theory
one could abuse the unicast address assignment mechanisms (in the
absence of anything else users might be tempted to try this). But that's
a different issue.

	MikaL
