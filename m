From: bert hubert <ahu@ds9a.nl>
Subject: Re: [PATCH,RFC] explicit connection confirmation
Date: Thu, 7 Nov 2002 17:24:24 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021107162424.GA31447@outpost.ds9a.nl>
References: <20021107093207.GA30666@gnu.org> <20021107112733.GA24283@outpost.ds9a.nl> <20021107120956.GA10832@gnu.org> <20021107134918.GA28329@outpost.ds9a.nl> <20021107143002.GA23858@gnu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@gnu.org>
Content-Disposition: inline
In-Reply-To: <20021107143002.GA23858@gnu.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Nov 07, 2002 at 09:30:02AM -0500, Lennert Buytenhek wrote:

> > I like having this ability - I dislike offering it to an unsuspecting
> > userspace.
> 
> Userspace needs to turn on the option first, so your 'unsuspecting'
> does not apply.

Ah ok, I thought 'TCP_CONFIRM_CONNECT' was a TCP connection state like
SYN_RECV.

> Again, if the app decides to turn on TCP_CONFIRM_CONNECT, then it's
> up to the app to deal with it properly.  There are very good reasons
> for not turning on TCP_CONFIRM_CONNECT by default, which is why it
> is not on by default, and why grafting a setsockopt onto every daemon
> there is out there is definitely not a good idea.

Exactly. Ok, cool. 

Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
