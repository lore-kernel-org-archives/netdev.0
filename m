From: jamal <hadi@cyberus.ca>
Subject: Re: dst cache overflow 2.2.x; x>=16
Date: Sun, 14 Apr 2002 15:43:38 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0204141543010.10326-100000@shell.cyberus.ca>
References: <Pine.GSO.4.30.0204141535550.10326-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: "Milam, Chad" <Chad_Milam@nyc.yr.com>
In-Reply-To: <Pine.GSO.4.30.0204141535550.10326-100000@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org



On Sun, 14 Apr 2002, jamal wrote:

>
> Hi,
>
> Why couldnt you just modify the parameters in /proc?
>
> -Increase the overflow threshold (you actually hardcode this)
> /proc/sys/net/ipv4/route/gc_thresh
> -decrease the gc timer
> /proc/sys/net/ipv4/route/gc_timeout

Sorry, you hardcoded /proc/sys/net/ipv4/route/gc_timeout
to 120 secs.

cheers,
jamal
