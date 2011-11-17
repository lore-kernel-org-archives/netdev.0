From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v6 3/9] kbuild: document RPS/XPS network
 Kconfig options
Date: Thu, 17 Nov 2011 04:19:12 +0100
Message-ID: <1321499952.3274.11.camel@edumazet-laptop>
References: <1321485122.2709.55.camel@bwh-desktop>
	 <CAG88wWZ853cHkykNbQ+Lqrk_D1p-SCmB0Y29YE6GpSSUORwCxg@mail.gmail.com>
	 <1321498443.2885.80.camel@deadeye>
	 <20111116.215901.100218898762260021.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, david.decotigny@google.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ian.campbell@citrix.com, jeffrey.t.kirsher@intel.com,
	jpirko@redhat.com, joe@perches.com, szymon@janc.net.pl,
	rick.jones2@hp.com, AAbdulla@nvidia.com, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111116.215901.100218898762260021.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 16 novembre 2011 =C3=A0 21:59 -0500, David Miller a =C3=A9c=
rit :

> They shouldn't be, they are internal dependency descriptions and shou=
ld
> be invisible to the user.

Unless someone has evidence of a performance cost :)

The rps_lock() adds an atomic operation in netif_rx(), even if RPS is
not really used/configured...
