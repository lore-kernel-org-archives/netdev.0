From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Thu, 26 Jan 2012 00:18:37 +0100
Message-ID: <CAA93jw5Juvb91wWt8=KbrxAW7nOdAUX82q+syMwv-+XJwgeSwA@mail.gmail.com>
References: <CAOzFzEjE7b-Y+_vOWeBKbHDkURRcYXomSTcwB91vKHVWQxBVsg@mail.gmail.com>
	<20120124.230203.1478271172075708903.davem@davemloft.net>
	<CAEP_g=9H9dV9=qtFPh4YeTNQ-t+UZGw-YqZ6hFWVNXjFy+GCZg@mail.gmail.com>
	<20120125.165548.596418893115900979.davem@davemloft.net>
	<CAGsizzJnRy74ni-HH=5q1VR4g6sfDPg9SFw4UKgSjJjkSR8OJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jesse@nicira.com,
	joseph.glanville@orionvm.com.au, eric.dumazet@gmail.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGsizzJnRy74ni-HH=5q1VR4g6sfDPg9SFw4UKgSjJjkSR8OJA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/1/25 =C5=A0tefan Gula <steweg@ynet.sk>:
> 2012/1/25 David Miller <davem@davemloft.net>:
>> From: Jesse Gross <jesse@nicira.com>
>> Date: Tue, 24 Jan 2012 23:11:06 -0800
>>
>>> On Tue, Jan 24, 2012 at 8:02 PM, David Miller <davem@davemloft.net>=
 wrote:
>>>> From: Joseph Glanville <joseph.glanville@orionvm.com.au>
>>>> Date: Wed, 25 Jan 2012 14:48:37 +1100
>>>>
>>>>> The reason why this patch is useful is that it stands to be the o=
nly
>>>>> true mulitpoint L2 VPN with a kernel space forwarding plane.
>>>>
>>>> So what you're telling me is that I added this huge openvswitch
>>>> thing essentially for nothing?
>>>
>>> I think it's actually the opposite - Open vSwitch can be used to
>>> implement this type of thing as well as for many other use cases.
>>
>> Then openvswitch is exactly where you should be prototyping and
>> implementing support for this sort of stuff.
>>
>> And only if you cannot obtain reasonable performance using openvswit=
ch
>> should you be even entertaining the notion of a static implementatio=
n.
>>
>> That's the whole premise behind putting openvswitch into the tree, s=
o
>> that guys like you can play around in userspace without having to ma=
ke
>> any kernel changes at all.
>>
>> I am not applying these patches, the more things you say the more I =
am
>> convinced they are not appropriate.
>>
> The performance is one of the most critical thing why I have chosen t=
o
> build kernel patch in the first place instead of some user-space app.

I am very interested in testing this patch, for the kinds of environmen=
ts
I care about (embedded, cpe, etc)

but I won't be able to get around to it for a week or so.

I found the overall simplicity of this approach vs the
complexity of the alternatives, appealing, and the
performance numbers also.

--=20
Dave T=C3=A4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
