From: jamal <hadi@cyberus.ca>
Subject: Re: dst cache overflow 2.2.x; x>=16
Date: Sun, 14 Apr 2002 15:39:36 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0204141535550.10326-100000@shell.cyberus.ca>
References: <D4CA6B275AA33241AC771F0C0B43A921011BE864@nyc285ex01.nyc.corp.yr.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: "Milam, Chad" <Chad_Milam@nyc.yr.com>
In-Reply-To: <D4CA6B275AA33241AC771F0C0B43A921011BE864@nyc285ex01.nyc.corp.yr.com>
List-Id: netdev.vger.kernel.org


Hi,

Why couldnt you just modify the parameters in /proc?

-Increase the overflow threshold (you actually hardcode this)
/proc/sys/net/ipv4/route/gc_thresh
-decrease the gc timer
/proc/sys/net/ipv4/route/gc_timeout

cheers,
jamal
