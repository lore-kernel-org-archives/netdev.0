From: Andi Kleen <ak@suse.de>
Subject: Re: socket(7) error?
Date: Thu, 21 Aug 2003 12:42:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030821104244.GC28496@wotan.suse.de>
References: <20030821031938.GA19630@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
Content-Disposition: inline
In-Reply-To: <20030821031938.GA19630@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Aug 21, 2003 at 04:19:38AM +0100, Matthew Wilcox wrote:
> 
> Hi.  There's a bug report from Martin Pool against manpages-dev suggesting
> the following paragraph from socket(7) is incorrect:
> 
>        SO_RCVTIMEO and SO_SNDTIMEO
>               Specify  the  sending  or  receiving timeouts until reporting an
>               error.  They are fixed to a protocol specific setting  in  Linux
>               and  cannot  be read or written. Their functionality can be emu-
>               lated using alarm(2) or setitimer(2).
> 
> He says:
> 
>    In fact, these options do seem to be at least partially implemented
>    in Linux 2.4.20.  You can at least set and retrieve a value against
>    a socket, and it does seem to affect the (complex) network scheduling
>    code.

It was correct when the manpage was written, but wasn't updated
later when option was implemented.

-Andi
