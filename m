From: bert hubert <ahu@ds9a.nl>
Subject: Re: [PATCH,RFC] explicit connection confirmation
Date: Thu, 7 Nov 2002 14:49:18 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021107134918.GA28329@outpost.ds9a.nl>
References: <20021107093207.GA30666@gnu.org> <20021107112733.GA24283@outpost.ds9a.nl> <20021107120956.GA10832@gnu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@gnu.org>
Content-Disposition: inline
In-Reply-To: <20021107120956.GA10832@gnu.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Nov 07, 2002 at 07:09:56AM -0500, Lennert Buytenhek wrote:

> > I think this approach smells, btw - doesn't this mean that processes
> > will now be woken up on receiving a SYN instead of after completion
> > of the handshake?
> 
> Yes, it does mean this.  You are free to suggest alternatives.

I like having this ability - I dislike offering it to an unsuspecting
userspace.

> > Would make a synflood all the more interesting..
> 
> In case of a synflood, the TCP stack will fall back to sending
> syncookies as it normally does.

Yes, but in your setup, a spoofable SYN packet will spawn a process for many
daemons, unless they are modified to first try to read/write to the socket
(which might block!) before forking/pthread_create()ing.

Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
