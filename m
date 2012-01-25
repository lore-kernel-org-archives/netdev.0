From: David Miller <davem@davemloft.net>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Wed, 25 Jan 2012 16:49:39 -0500 (EST)
Message-ID: <20120125.164939.1360578908839469758.davem@davemloft.net>
References: <3900291.2831326843194846.JavaMail.root@5-MeO-DMT.ynet.sk>
	<20120125085712.524b65a8@nehalam.linuxnetplumber.net>
	<CAGsizzKAvAV771vSo0TGx_sU5qXgjOOqVRooK9vOf=XEi1NtXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: steweg@ynet.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGsizzKAvAV771vSo0TGx_sU5qXgjOOqVRooK9vOf=XEi1NtXA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =A6tefan Gula <steweg@ynet.sk>
Date: Wed, 25 Jan 2012 22:01:08 +0100

> 2012/1/25 Stephen Hemminger <shemminger@vyatta.com>:
>> On Wed, 18 Jan 2012 00:33:14 +0100 (CET)
>> Stefan Gula <steweg@ynet.sk> wrote:
>>
>>> From: Stefan Gula <steweg@gmail.com>
>>>
>>> This patch is an extension for current Ethernet over GRE
>>> implementation, which allows user to create virtual bridge (multipo=
int
>>> VPN) and forward traffic based on Ethernet MAC address information =
in
>>> it. It simulates the Bridge behavior learning mechanism, but instea=
d
>>> of learning port ID from which given MAC address comes, it learns I=
P
>>> address of peer which encapsulated given packet. Multicast, Broadca=
st
>>> and unknown-multicast traffic is send over network as multicast
>>> encapsulated GRE packet, so one Ethernet multipoint GRE tunnel can =
be
>>> represented as one single virtual switch on logical level and be al=
so
>>> represented as one multicast IPv4 address on network level.
>>>
>>> Signed-off-by: Stefan Gula <steweg@gmail.com>
>>
>> Will this break normal usages of GRE?
>> Compile time options are not acceptable for a standard distribution =
if
>> it will break it for the other case. It is fine to add the additiona=
l data
>> structure elements, but the code in the receive path might get broke=
n?
>>
>>
> No, if you don't decide to compile with given kernel option.. nothing
> happens and original GRE code is leaved intact.

Every distribution is going to want to turn the option on to provide
the feature to their users, so this line of reasoning is not
acceptable.
