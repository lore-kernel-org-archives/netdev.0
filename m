From: kuznet@ms2.inr.ac.ru
Subject: Re: "new style" netdevice allocation patch for TUN driver (2.4.18 kernel)
Date: Thu, 1 Aug 2002 21:43:23 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208011743.VAA07150@sex.inr.ac.ru>
References: <20020801133506.GA22073@serwus.bnet.pl>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: jajcus@bnet.pl
In-Reply-To: <20020801133506.GA22073@serwus.bnet.pl> from "Jacek Konieczny" at Aug 1, 2 05:45:01 pm
List-Id: netdev.vger.kernel.org

Hello!

> network. And "unregister_netdevice: waiting for tun0 to become free"

This smells like a leakage. I think this should be investigated.


> devices, and that only the "old style" devices have this problem.
> I had similar problem with VLAN devices some time ago, so I checked VLAN
> driver sources too.

Well, switching to "new style" does not solve the problem. If we have
a leakage, it will continue silently which is even worse.
Probably, you should to define NET_REFCNT_DEBUG in net/core/dev.c
to track what happens with the device.

Alexey
