From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Wed, 25 Jan 2012 22:01:08 +0100
Message-ID: <CAGsizzKAvAV771vSo0TGx_sU5qXgjOOqVRooK9vOf=XEi1NtXA@mail.gmail.com>
References: <18947389.2811326843064500.JavaMail.root@5-MeO-DMT.ynet.sk>
 <3900291.2831326843194846.JavaMail.root@5-MeO-DMT.ynet.sk> <20120125085712.524b65a8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120125085712.524b65a8@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/1/25 Stephen Hemminger <shemminger@vyatta.com>:
> On Wed, 18 Jan 2012 00:33:14 +0100 (CET)
> Stefan Gula <steweg@ynet.sk> wrote:
>
>> From: Stefan Gula <steweg@gmail.com>
>>
>> This patch is an extension for current Ethernet over GRE
>> implementation, which allows user to create virtual bridge (multipoint
>> VPN) and forward traffic based on Ethernet MAC address information in
>> it. It simulates the Bridge behavior learning mechanism, but instead
>> of learning port ID from which given MAC address comes, it learns IP
>> address of peer which encapsulated given packet. Multicast, Broadcast
>> and unknown-multicast traffic is send over network as multicast
>> encapsulated GRE packet, so one Ethernet multipoint GRE tunnel can be
>> represented as one single virtual switch on logical level and be also
>> represented as one multicast IPv4 address on network level.
>>
>> Signed-off-by: Stefan Gula <steweg@gmail.com>
>
> Will this break normal usages of GRE?
> Compile time options are not acceptable for a standard distribution if
> it will break it for the other case. It is fine to add the additional data
> structure elements, but the code in the receive path might get broken?
>
>
No, if you don't decide to compile with given kernel option.. nothing
happens and original GRE code is leaved intact.
