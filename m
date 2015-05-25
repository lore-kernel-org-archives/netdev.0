From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next] bridge: allow setting hash_max +
 multicast_router if interface is down
Date: Mon, 25 May 2015 17:28:18 -0400 (EDT)
Message-ID: <20150525.172818.2000334376621437405.davem@davemloft.net>
References: <1432343554-3493-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, stephen@networkplumber.org,
	herbert@gondor.apana.org.au, roopa@cumulusnetworks.com,
	cwang@twopensource.com, sashok@cumulusnetworks.com,
	wkok@cumulusnetworks.com
To: linus.luessing@c0d3.blue
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432343554-3493-1-git-send-email-linus.luessing@c0d3.blue>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Linus L=FCssing <linus.luessing@c0d3.blue>
Date: Sat, 23 May 2015 03:12:34 +0200

> Network managers like netifd (used in OpenWRT for instance) try to
> configure interface options after creation but before setting the
> interface up.
>=20
> Unfortunately the sysfs / bridge currently only allows to configure t=
he
> hash_max and multicast_router options when the bridge interface is up=
=2E
> But since br_multicast_init() doesn't start any timers and only sets
> default values and initializes timers it should be save to reconfigur=
e
> the default values after that, before things actually get active afte=
r
> the bridge is set up.
>=20
> Signed-off-by: Linus L=FCssing <linus.luessing@c0d3.blue>

Applied to net-next, thanks.
