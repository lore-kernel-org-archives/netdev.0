From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Wed, 25 Jan 2012 23:57:18 +0100
Message-ID: <CAGsizzJnRy74ni-HH=5q1VR4g6sfDPg9SFw4UKgSjJjkSR8OJA@mail.gmail.com>
References: <CAOzFzEjE7b-Y+_vOWeBKbHDkURRcYXomSTcwB91vKHVWQxBVsg@mail.gmail.com>
 <20120124.230203.1478271172075708903.davem@davemloft.net> <CAEP_g=9H9dV9=qtFPh4YeTNQ-t+UZGw-YqZ6hFWVNXjFy+GCZg@mail.gmail.com>
 <20120125.165548.596418893115900979.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: jesse@nicira.com, joseph.glanville@orionvm.com.au,
	eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120125.165548.596418893115900979.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/1/25 David Miller <davem@davemloft.net>:
> From: Jesse Gross <jesse@nicira.com>
> Date: Tue, 24 Jan 2012 23:11:06 -0800
>
>> On Tue, Jan 24, 2012 at 8:02 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Joseph Glanville <joseph.glanville@orionvm.com.au>
>>> Date: Wed, 25 Jan 2012 14:48:37 +1100
>>>
>>>> The reason why this patch is useful is that it stands to be the only
>>>> true mulitpoint L2 VPN with a kernel space forwarding plane.
>>>
>>> So what you're telling me is that I added this huge openvswitch
>>> thing essentially for nothing?
>>
>> I think it's actually the opposite - Open vSwitch can be used to
>> implement this type of thing as well as for many other use cases.
>
> Then openvswitch is exactly where you should be prototyping and
> implementing support for this sort of stuff.
>
> And only if you cannot obtain reasonable performance using openvswitch
> should you be even entertaining the notion of a static implementation.
>
> That's the whole premise behind putting openvswitch into the tree, so
> that guys like you can play around in userspace without having to make
> any kernel changes at all.
>
> I am not applying these patches, the more things you say the more I am
> convinced they are not appropriate.
>
The performance is one of the most critical thing why I have chosen to
build kernel patch in the first place instead of some user-space app.
If I used this approach, I would probably end up with patch for
OpenVPN project instead in that time. I am not telling that
openvswitch is not a good place for prototyping, but I believe that
this patch is beyond that border as it successfully run in environment
with more 98 linux-based APs, used for 4K+ users, with no issue for
more than 2 years. The performance results from Joseph Glanville even
adds value to it. So I still don't get the point, why my patch and
openvswitch cannot coexists in the kernel together and let user/admin
to choose to correct solution for him/her.
