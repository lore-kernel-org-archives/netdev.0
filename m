From: jamal <hadi@cyberus.ca>
Subject: RE: dst cache overflow 2.2.x; x>=16
Date: Mon, 15 Apr 2002 14:27:05 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0204151422480.15824-100000@shell.cyberus.ca>
References: <D4CA6B275AA33241AC771F0C0B43A921011BE869@nyc285ex01.nyc.corp.yr.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: "Milam, Chad" <Chad_Milam@nyc.yr.com>
In-Reply-To: <D4CA6B275AA33241AC771F0C0B43A921011BE869@nyc285ex01.nyc.corp.yr.com>
List-Id: netdev.vger.kernel.org



On Mon, 15 Apr 2002, Milam, Chad wrote:

> the fact that i am using 2.2 is stated in the subject line. i did neglect to
> put it explicitly put it in the message (sorry).  it is, however, also
> diff/patch file.

I apologize. I spent all my time rambling to you based on 2.4 code ;-<

>
> I also do not think that nuking valid routes in the cache will produce any
> major issues, other than slowing things down for a few seconds.  the cache
> is just the cache, not the real route table. and yes, it pretty much
> guarantees the route cache will be purged, therefore avoiding a reboot and
> avoiding a quickly repeated overflow...
>

Typically most of the code will check for the dst cache or some
dereferencing within it before using it. I am not sure we can
swear by this ;-> i suppose we will find out when you get an oops ;->
maybe you should just purge the routes marked as expired.

cheers,
jamal
