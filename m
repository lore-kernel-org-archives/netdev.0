From: jamal <hadi@cyberus.ca>
Subject: RE: dst cache overflow 2.2.x; x>=16
Date: Sun, 14 Apr 2002 16:32:20 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0204141627370.10326-100000@shell.cyberus.ca>
References: <D4CA6B275AA33241AC771F0C0B43A921011BE866@nyc285ex01.nyc.corp.yr.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: "Milam, Chad" <Chad_Milam@nyc.yr.com>
In-Reply-To: <D4CA6B275AA33241AC771F0C0B43A921011BE866@nyc285ex01.nyc.corp.yr.com>
List-Id: netdev.vger.kernel.org



On Sun, 14 Apr 2002, Milam, Chad wrote:

> /proc/sys/net/ipv4/route/max_size=16384 (default 4096)

Ok, i meant:
/proc/sys/net/ipv4/route/gc_thresh

> Also, based on the code from route.c:
> --
> if (atomic_read(&ipv4_dst_ops.entries) < ip_rt_max_size)
>         return 0;
> if (net_ratelimit())
> 	printk("dst cache overflow\n");
> return 1;
> --
>

0 typically means the gc was succesful

> Looks to me like gc_thresh has nothing to do with it. Did I read that wrong?
>

I just remembered an old problem that used to cause this; do you
have lo configured?
make sure it is IP address 127.0.0.1 and it is up.

cheers,
jamal
