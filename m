From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] net: Allow no-cache copy from user on transmit
Date: Wed, 09 Mar 2011 19:38:31 +0000
Message-ID: <1299699511.3006.6.camel@bwh-desktop>
References: <alpine.DEB.2.00.1103082053350.1433@pokey.mtv.corp.google.com>
	 <AANLkTikFSRr649_P8V8J7Xj_KY8hSEw23RBAyyV2wUQr@mail.gmail.com>
	 <AANLkTiknMqNOQKiKpVaDy=zXCXuOxZaQTjKmmxY_bRC5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:6210 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272Ab1CITie convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 14:38:34 -0500
In-Reply-To: <AANLkTiknMqNOQKiKpVaDy=zXCXuOxZaQTjKmmxY_bRC5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-03-09 at 11:18 -0800, Tom Herbert wrote:
> > Please don't add new get/set ops for netdev features - G/SFEATURES
> > handle them all.
> >
> > Proper way is to modify NETIF_F_ETHTOOL_BITS, netdev_fix_features()
> > and, if needed for now,
> > legacy get/set ops (they will go away, eventually).
> >
>=20
> Don't see this in
> git://git.kernel.org/pub/scm/network/ethtool/ethtool.  Has the patch
> been applied?

I haven't changed ethtool yet.  I put some patches out for discussion
and Micha=C5=82 found some problems for them; I haven't had the time to
revise them yet.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

