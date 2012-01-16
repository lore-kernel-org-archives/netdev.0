From: David Lamparter <equinox@diac24.net>
Subject: Re: [patch v1, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Mon, 16 Jan 2012 14:35:05 +0100
Message-ID: <20120116133505.GE1077372@jupiter.n2.diac24.net>
References: <CAGsizzJTbGGpwrn-P=SUtqBW=1AN6hCTVXKp_oKHPBAoGZ4ubA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?utf-8?Q?=C5=A0tefan?= Gula <steweg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGsizzJTbGGpwrn-P=SUtqBW=1AN6hCTVXKp_oKHPBAoGZ4ubA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 16, 2012 at 01:13:19PM +0100, =C5=A0tefan Gula wrote:
> it learns IP address of peer which encapsulated given packet.

This feature is already present in the Linux kernel, albeit only for IP
to IP lookup. Please look at "userspace ARPd" and its relation to
multipoint GRE. OpenNHRP is the associated userspace part.

That code reuses the existing neighbor management infrastructure. Addin=
g
support for gretap and automatic learning from incoming packets
shouldn't be too hard...


-David
