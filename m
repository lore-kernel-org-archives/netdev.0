From: "Bas Bloemsaat" <bloemsaa@xs4all.nl>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Mon, 28 Jul 2003 09:33:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <01a601c354da$9710cc10$cd01a8c0@llewella>
References: <Pine.LNX.4.53.0307272239570.2743@vialle.bloemsaat.com> <20030727151234.6e2aa57e.davem@redhat.com> <3F248AE5.4000204@candelatech.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Ben Greear" <greearb@candelatech.com>,
   "David S. Miller" <davem@redhat.com>,
   "Carlos Velasco" <carlosev@newipnet.com>, <netdev@oss.sgi.com>,
   <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

> > Not a bug.  This behavior is on purpose.
First of all I'm sorry I rubbed some old sores. I didn't know the behaviour was on purpose, and I did google for it. Could have
saved my weekend, had I known.

> >Bas's problem can be solved by him giving a "preferred source"
> >to each of his IPV4 routes and setting the "arpfilter" sysctl
> >variable for his devices to "1".
>
> Yes, it's another approach to solve his problem. But he must play with routing.

Routing isn't solving anything here, it's too dynamic. Only one of the devices has a fixed IP, and handles a link to the outside,
among others. The other is on DHCP: addresses can change without warning. Both are on the same ethernet segment.

I've looked at the hidden patch, and it's capable of doing this right. I do think this has to be solved at the device layer. It's
quite counter intuitive the way it is now. My vote goes to hidden.

Regards,
Bas
