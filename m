From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next af-packet 1/2] Enhance af-packet to provide
 (near zero)lossless packet capture functionality.
Date: Tue, 05 Jul 2011 08:01:23 -0700 (PDT)
Message-ID: <20110705.080123.2174577714045488116.davem@davemloft.net>
References: <1308708650-25509-2-git-send-email-loke.chetan@gmail.com>
	<20110701.153633.267893668051099806.davem@davemloft.net>
	<CAAsGZS5vvmb_qX+cG507=hU_+kwnowEEojXGNMt5ShEZ9+ZeAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, joe@perches.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org
To: loke.chetan@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAsGZS5vvmb_qX+cG507=hU_+kwnowEEojXGNMt5ShEZ9+ZeAA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: chetan loke <loke.chetan@gmail.com>
Date: Tue, 5 Jul 2011 10:53:26 -0400

>> Next, having this overlay thing is entirely pointless. =A0Just refer=
 to
>=20
> It is useful.
> Also, future versions of the block-descriptor can append a new field.
> When that happens,
> none of the code needs to worry about the version etc for the unchang=
ed fields.

That issue only exists because you haven't defined a common header
struct that the current, and all future, block descriptor variants can
include at the start of their definitions.

I still contend that all of these abstractions are too much and
unnecessary.

Use real data structures, not opaque "offset+size" poking into the
descriptors.
