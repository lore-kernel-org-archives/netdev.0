From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix IXP4xx coherent allocations
Date: Sat, 23 Mar 2013 19:57:40 -0400 (EDT)
Message-ID: <20130323.195740.2108147521543354261.davem@davemloft.net>
References: <m3obe9lxil.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, c.aeschlimann@acn-group.ch
To: khc@pm.waw.pl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m3obe9lxil.fsf@intrepid.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Krzysztof Halasa <khc@pm.waw.pl>
Date: Sat, 23 Mar 2013 20:35:46 +0100

> ARM core code currently requires coherent DMA mask to be set. Make su=
re
> we limit PCI devices to 64 MiB while allowing on-chip devices to acce=
ss
> the whole 4 GiB address space.
>=20
> This fixes a v3.7+ regression which broke IXP4xx built-in network dev=
ices.
>=20
> Signed-off-by: Krzysztof Ha=A9=A9asa <khc@pm.waw.pl>

This requirement is not reasonable.

The DMA API documentation clearly states what the default must be,
and what drivers are guarenteed will be the default.
