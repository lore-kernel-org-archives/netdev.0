From: bert hubert <ahu@ds9a.nl>
Subject: Re: [PATCH,RFC] explicit connection confirmation
Date: Thu, 7 Nov 2002 12:27:33 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021107112733.GA24283@outpost.ds9a.nl>
References: <20021107093207.GA30666@gnu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@gnu.org>
Content-Disposition: inline
In-Reply-To: <20021107093207.GA30666@gnu.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Nov 07, 2002 at 04:32:08AM -0500, Lennert Buytenhek wrote:

> - Sockets returned from accept() on this socket after this will be
>   sockets in the SYN_RECV state instead of the ESTABLISHED state
>   (unless syncookies had to be used).  By writing to the socket,
>   you cause a SYN-ACK to be sent, and by immediately closing the
>   socket you cause a RST to be sent.

And reading, like a webserver would do? I think this approach smells, btw -
doesn't this mean that processes will now be woken up on receiving a SYN
instead of after completion of the handshake?

Would make a synflood all the more interesting..

Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
