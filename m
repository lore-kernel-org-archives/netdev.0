From: jamal <hadi@cyberus.ca>
Subject: RE: dst cache overflow 2.2.x; x>=16
Date: Sun, 14 Apr 2002 16:53:30 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0204141644390.10326-100000@shell.cyberus.ca>
References: <D4CA6B275AA33241AC771F0C0B43A921011BE867@nyc285ex01.nyc.corp.yr.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: "Milam, Chad" <Chad_Milam@nyc.yr.com>
In-Reply-To: <D4CA6B275AA33241AC771F0C0B43A921011BE867@nyc285ex01.nyc.corp.yr.com>
List-Id: netdev.vger.kernel.org




If i summarize your problem is that you are building up
dst caches faster than they can be garbage collected.

Solution
1. Make the max size large enough to catchup with rate
2. Make sure that every time you go into garbage collection you are
successful.
- reducing the min interval to 1 might be a little aggressive.
But you can tune this later
- You wanna make sure you get a large positive "goal" every time
play with ip_rt_gc_elasticity (/proc/sys/net/ipv4/route/gc_elasticity)
also the rt_hash_log

All the above are configurable via /proc

have to run

cheers,
jamal
