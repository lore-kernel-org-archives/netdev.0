From: bert hubert <ahu@ds9a.nl>
Subject: Re: [PATCH,RFC] explicit connection confirmation
Date: Fri, 8 Nov 2002 12:52:05 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021108115205.GA20549@outpost.ds9a.nl>
References: <20021107152758.GB23858@gnu.org> <Pine.GSO.4.30.0211080605410.14675-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@gnu.org>, Marc Boucher <marc@mbsi.ca>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.30.0211080605410.14675-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Nov 08, 2002 at 06:22:00AM -0500, jamal wrote:

> > There was a thread about this in private mail round April this year,
> > in which some good points were raised.
> 
> There are some good points; however, whats the app for this feature?

This came up a long time ago on bugtraq in a discussion how to easily
prevent certain IP addresses from DoSsing your TCP daemon. Right now,
userspace is always forced to complete the threeway handshake, and can only
then close the socket.

Even rather small amounts of SYN packets can thus easily saturate a server
which has decided to handle only 100 connections AND has decided to ignore a
certain IP address. Some inetd superservers contain code to ratelimit IP
addresses which sadly is not as effective from userspace as it could be with
the ability to RST a connection immediately.

It also allows userspace to simulate that a service isn't even there,
without root capabilities.

Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
