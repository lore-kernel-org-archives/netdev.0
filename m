From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Fix IXP4xx coherent allocations
Date: Sun, 24 Mar 2013 19:11:07 +0000
Message-ID: <1364152267.3620.31.camel@deadeye.wl.decadent.org.uk>
References: <m3obe9lxil.fsf@intrepid.localdomain>
	 <20130323.195740.2108147521543354261.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <khc@pm.waw.pl>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <c.aeschlimann@acn-group.ch>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130323.195740.2108147521543354261.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-03-23 at 19:57 -0400, David Miller wrote:
> From: Krzysztof Halasa <khc@pm.waw.pl>
> Date: Sat, 23 Mar 2013 20:35:46 +0100
>=20
> > ARM core code currently requires coherent DMA mask to be set. Make =
sure
> > we limit PCI devices to 64 MiB while allowing on-chip devices to ac=
cess
> > the whole 4 GiB address space.
> >=20
> > This fixes a v3.7+ regression which broke IXP4xx built-in network d=
evices.
> >=20
> > Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
>=20
> This requirement is not reasonable.
>=20
> The DMA API documentation clearly states what the default must be,
> and what drivers are guarenteed will be the default.

I'm failing to see where it says the default can't be narrower than 32
bits due to platform limits.  And how do you think DMA mapping is
supposed to work for PCI devices on these platforms, anyway?

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
