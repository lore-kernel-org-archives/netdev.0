From: bert hubert <ahu@ds9a.nl>
Subject: Re: (udp-en/decap broken in 2.6.8-rc2?) Re: ipsec, nat-t, iproute2?
Date: Sat, 31 Jul 2004 10:34:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040731083456.GA24761@outpost.ds9a.nl>
References: <20040730223808.GA12660@outpost.ds9a.nl> <E1Bqod3-0004FB-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1Bqod3-0004FB-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jul 31, 2004 at 05:50:05PM +1000, Herbert Xu wrote:

> You need to have someone open a socket on port 4500 and do the
> appropriate setsockopt() on it.

Would this be:
#define UDP_ESPINUDP    100, known in the kernel as UDP_ENCAP?

Does the socket need to be kept open after the setsockopt? Do the
encapsulated packets reach userspace?

The right way to do this is probably to first get a socket, set it to
UDP_ENCAP, and only then try to negotiate an SA, using the port number
assigned previously?

> > This is the setkey configuration I use on 10.0.0.3:
> 
> Any reason why you aren't using automatic keying?

I'm trying to figure out how this stuff works with an eye on documenting it.
So far I haven't been able to get openswan to do nat-t, hence I've been
trying to do this from the ground up.

Thanks.

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
