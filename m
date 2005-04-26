From: Andi Kleen <ak@muc.de>
Subject: Re: is UDP_CORK "real"
Date: Tue, 26 Apr 2005 15:40:22 +0200
Message-ID: <m1u0lty7uh.fsf@muc.de>
References: <426833F0.9010803@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <426833F0.9010803@hp.com> (Rick Jones's message of "Thu, 21 Apr
 2005 16:14:56 -0700")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rick Jones <rick.jones2@hp.com> writes:
> today? While man tcp described TCP_CORK, on the two places I've
> checked thusfar, man udp does not describe UDP_CORK.  I'm not sure if
> that means UDP_CORK is "unreal" or just that the udp manpage needs
> repair (or was out of date on my systems).

AFAIK nobody has been updating the protocol manpages since I stopped
doing so several years ago when they were included into the
standard manpages.  There are lots of missing features
etc. that could be documented, the BUGS sections are usually 
out of date etc. It is roughly at the state of early 2.3.

There is also unfortunately no policy to require a manpage
update when a new feature is added to the kernel.

Some manpages have been even never fully written like the ipv6 manpage.
Perhaps someone is interested in updating all these? It unfortunately
needs quite a lot of RTFS to figure out what the code actually does.

-Andi
