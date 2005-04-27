From: Andi Kleen <ak@muc.de>
Subject: network manpages was Re: is UDP_CORK "real"
Date: 27 Apr 2005 14:26:48 +0200
Message-ID: <20050427122648.GA12597@muc.de>
References: <426833F0.9010803@hp.com> <m1u0lty7uh.fsf@muc.de> <426F2A1D.10001@aarnet.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Wed, 27 Apr 2005 14:26:48 +0200
To: Glen Turner <glen.turner@aarnet.edu.au>
Content-Disposition: inline
In-Reply-To: <426F2A1D.10001@aarnet.edu.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Apr 27, 2005 at 03:28:53PM +0930, Glen Turner wrote:
> Please mail me with what you think is required here.  I've
> been getting grief from our high performance users on
> exactly this point (and the sysctl maze of twisty options)

sysctl is mostly documented in Documentation/*.  
Also the sysctls change sometimes, so I am not sure it is a good idea
to put them into the manpages which are supposed to be more version
independent.  At least I would only put the more important ones there.

In particular the ipv6 protocol manpage needs a rewrite, it was only a 
relatively poor quick&dirty job. For the others it would be probably
sufficient to just check what new ioctls/socket options are missing
and document them and perhaps check if the NOTES/BUGS caveats still
apply. An sctp manpage is also lacking I think, that was a completely
new protocol.

It would be nice of course if David could enforce a policy
to require a manpage patch for new ioctls/socket options etc.
in the future, then such documentation lag would not happen.

-Andi
