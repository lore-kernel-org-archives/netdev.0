From: Lennert Buytenhek <buytenh@gnu.org>
Subject: Re: [PATCH,RFC] explicit connection confirmation
Date: Thu, 7 Nov 2002 07:09:56 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021107120956.GA10832@gnu.org>
References: <20021107093207.GA30666@gnu.org> <20021107112733.GA24283@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20021107112733.GA24283@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Thu, Nov 07, 2002 at 12:27:33PM +0100, bert hubert wrote:

> > - Sockets returned from accept() on this socket after this will be
> >   sockets in the SYN_RECV state instead of the ESTABLISHED state
> >   (unless syncookies had to be used).  By writing to the socket,
> >   you cause a SYN-ACK to be sent, and by immediately closing the
> >   socket you cause a RST to be sent.
> 
> And reading, like a webserver would do?

Will do nothing, but this can easily be changed.

I remind you of the fact that this option has to be explicitly
enabled on a listening socket, so that apps have to be adapted to
use the new interface anyway.


> I think this approach smells, btw - doesn't this mean that processes
> will now be woken up on receiving a SYN instead of after completion
> of the handshake?

Yes, it does mean this.  You are free to suggest alternatives.


> Would make a synflood all the more interesting..

In case of a synflood, the TCP stack will fall back to sending
syncookies as it normally does.


cheers,
Lennert
