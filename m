From: Jesse Gross <jesse@nicira.com>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Tue, 24 Jan 2012 23:11:06 -0800
Message-ID: <CAEP_g=9H9dV9=qtFPh4YeTNQ-t+UZGw-YqZ6hFWVNXjFy+GCZg@mail.gmail.com>
References: <20120123.134352.1621146585245670953.davem@davemloft.net>
 <CAGsizzJnQ6b6eSC0ZnAtFguU7_xDfWFPSY6L4DWXc24F+Ts2XQ@mail.gmail.com>
 <CAOzFzEjE7b-Y+_vOWeBKbHDkURRcYXomSTcwB91vKHVWQxBVsg@mail.gmail.com> <20120124.230203.1478271172075708903.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: joseph.glanville@orionvm.com.au, steweg@ynet.sk,
	eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120124.230203.1478271172075708903.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 24, 2012 at 8:02 PM, David Miller <davem@davemloft.net> wrote:
> From: Joseph Glanville <joseph.glanville@orionvm.com.au>
> Date: Wed, 25 Jan 2012 14:48:37 +1100
>
>> The reason why this patch is useful is that it stands to be the only
>> true mulitpoint L2 VPN with a kernel space forwarding plane.
>
> So what you're telling me is that I added this huge openvswitch
> thing essentially for nothing?

I think it's actually the opposite - Open vSwitch can be used to
implement this type of thing as well as for many other use cases.  On
the other hand, even when implementing a multipoint L2 solution it can
be useful to have additional levels of control but you can't do that
with this patch because it essentially statically glues together
tunneling and bridging.
