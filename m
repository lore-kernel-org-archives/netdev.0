From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch v1, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Mon, 16 Jan 2012 08:36:34 -0800
Message-ID: <20120116083634.7b327c34@nehalam.linuxnetplumber.net>
References: <CAGsizzJTbGGpwrn-P=SUtqBW=1AN6hCTVXKp_oKHPBAoGZ4ubA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?UTF-8?B?xaB0ZWZhbg==?= Gula <steweg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGsizzJTbGGpwrn-P=SUtqBW=1AN6hCTVXKp_oKHPBAoGZ4ubA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Jan 2012 13:13:19 +0100
=C5=A0tefan Gula <steweg@gmail.com> wrote:

> From: Stefan Gula <steweg@gmail.com
>=20
> This patch is an extension for current Ethernet over GRE
> implementation, which allows user to create virtual bridge (multipoin=
t
> VPN) and forward traffic based on Ethernet MAC address informations i=
n
> it. It simulates the Bridge bahaviour learing mechanism, but instead
> of learning port ID from which given MAC address comes, it learns IP
> address of peer which encapsulated given packet. Multicast, Broadcast
> and unknown-multicast traffic is send over network as multicast
> enacapsulated GRE packet, so one Ethernet multipoint GRE tunnel can b=
e
> represented as one single virtual switch on logical level and be also
> represented as one multicast IPv4 address on network level.
>=20
> Signed-off-by: Stefan Gula <steweg@gmail.com>

Thanks for the effort, but it is duplicating existing functionality.
It possible to do this already with existing gretap device and the
current bridge.

The same thing is also supported by OpenVswitch.
