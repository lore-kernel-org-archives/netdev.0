From: David Miller <davem@davemloft.net>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Wed, 25 Jan 2012 16:55:48 -0500 (EST)
Message-ID: <20120125.165548.596418893115900979.davem@davemloft.net>
References: <CAOzFzEjE7b-Y+_vOWeBKbHDkURRcYXomSTcwB91vKHVWQxBVsg@mail.gmail.com>
	<20120124.230203.1478271172075708903.davem@davemloft.net>
	<CAEP_g=9H9dV9=qtFPh4YeTNQ-t+UZGw-YqZ6hFWVNXjFy+GCZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joseph.glanville@orionvm.com.au, steweg@ynet.sk,
	eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jesse@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEP_g=9H9dV9=qtFPh4YeTNQ-t+UZGw-YqZ6hFWVNXjFy+GCZg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Gross <jesse@nicira.com>
Date: Tue, 24 Jan 2012 23:11:06 -0800

> On Tue, Jan 24, 2012 at 8:02 PM, David Miller <davem@davemloft.net> wrote:
>> From: Joseph Glanville <joseph.glanville@orionvm.com.au>
>> Date: Wed, 25 Jan 2012 14:48:37 +1100
>>
>>> The reason why this patch is useful is that it stands to be the only
>>> true mulitpoint L2 VPN with a kernel space forwarding plane.
>>
>> So what you're telling me is that I added this huge openvswitch
>> thing essentially for nothing?
> 
> I think it's actually the opposite - Open vSwitch can be used to
> implement this type of thing as well as for many other use cases.

Then openvswitch is exactly where you should be prototyping and
implementing support for this sort of stuff.

And only if you cannot obtain reasonable performance using openvswitch
should you be even entertaining the notion of a static implementation.

That's the whole premise behind putting openvswitch into the tree, so
that guys like you can play around in userspace without having to make
any kernel changes at all.

I am not applying these patches, the more things you say the more I am
convinced they are not appropriate.
