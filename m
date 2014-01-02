From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] IPv6: add option to use Subnet-Router anycast addresses as source addresses
Date: Fri, 3 Jan 2014 00:19:21 +0100
Message-ID: <20140102231921.GI22494@order.stressinduktion.org>
References: <1388688977.95873.YahooMailBasic@web125502.mail.ne1.yahoo.com> <20140102231730.GH22494@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?utf-8?Q?Fran=C3=A7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36159 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbaABXTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 18:19:23 -0500
Content-Disposition: inline
In-Reply-To: <20140102231730.GH22494@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 03, 2014 at 12:17:30AM +0100, Hannes Frederic Sowa wrote:
> On Thu, Jan 02, 2014 at 10:56:17AM -0800, Fran=C3=A7ois-Xavier Le Bai=
l wrote:
> > > I wouldn't actually add this knob, we can just enable that by def=
ault.
> >=20
> > I think we need to keep by default the existing behaviour (ICMPv6 e=
cho reply with unicast)
> > in case some setups use it, and use "enable_anycast_src" to change =
the behaviour=20
> > according to RFC4942.
>=20
> We try to extract the destination address and reuse it in the reply. =
The
> other system should not notice if it communicates with a unicast or
> anycast address. Am I missing something?

Ah, I guess you are hinting at the situation where you ping a pre-defin=
ed
anycast address and expect back a unicast address for discovering the u=
nicast
address of a router e.g.? Ok, I see...
