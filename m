From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Wrong UIDs reported in /proc/net/tcp
Date: Fri, 19 Nov 2004 08:03:07 +1100
Message-ID: <20041118210307.GA9557@gondor.apana.org.au>
References: <20041109205358.GA64015@calma.pair.com> <E1CRdBr-0001P2-00@gondolin.me.apana.org.au> <20041118190257.GA7084@calma.pair.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Chad N. Tindel" <chad@tindel.net>
Content-Disposition: inline
In-Reply-To: <20041118190257.GA7084@calma.pair.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Nov 18, 2004 at 02:02:57PM -0500, Chad N. Tindel wrote:
> 
> OK, so just out of sheer morbid curiousity, I added an ioctl which will
> accept 4 parameters (the address/port pairs), and will return the user id
> associated with that socket.  I also changed pidentd to call this ioctl
> instead of looking at /proc/net/tcp.  This should theoretically get rid
> of all race conditions.

Please show us the code of your ioctl.

Have you tried netlink yet? Does it exhibit the same problem?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
