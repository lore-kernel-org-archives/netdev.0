From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to
 physical device
Date: Thu, 02 Jun 2011 21:51:46 +0100
Message-ID: <1307047906.2812.61.camel@bwh-desktop>
References: <20110602194621.GB2749@hmsreliant.think-freely.org>
	 <20110602.130448.917724318321380583.davem@davemloft.net>
	 <4DE7EF05.8030505@gmail.com>
	 <20110602.134637.1101638217263464114.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.2p.debian@gmail.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:35770 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752788Ab1FBUvu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 16:51:50 -0400
In-Reply-To: <20110602.134637.1101638217263464114.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-02 at 13:46 -0700, David Miller wrote:
> From: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@gmail.com>
> Date: Thu, 02 Jun 2011 22:13:57 +0200
>=20
> > To be more precise, due to the way bonding use queue mapping for sl=
ave
> > selection, it is desirable to clear the mapping before sending to t=
he
> > slave, because the meaning of the mapping for the slave interface
> > might be really different from the meaning for the bonding
> > interface. Arguably, this is the mapping usage in bonding which is
> > "different" from other usages, but...
>=20
> This just confirms my reasoning behind why I wanted to discourage
> drivers from providing explicit ->ndo_select_queue() methods unless
> absolutely necessary.
>=20
> Information now gets lost in cases like this bonding issue.
>=20
> Bonding should definitely, as I suggested, remember the original
> rxhash value and restore it when sending to the slave.

Surely RX queue (queue_mapping), not RX hash (rxhash, which is unchange=
d
anyway AFAIK).

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

