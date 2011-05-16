From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT
 return
Date: Mon, 16 May 2011 15:53:17 +0100
Message-ID: <1305557597.2885.5.camel@bwh-desktop>
References: <20110516121339.GA1094@rere.qmqm.pl>
	 <1305335142.2851.70.camel@bwh-desktop> <20110514103539.GA5214@rere.qmqm.pl>
	 <1305513923.19966.20.camel@localhost>
	 <20110516132807.1A89F13A6A@rere.qmqm.pl>
	 <1305553066.19966.32.camel@localhost>  <20110516142340.GA2980@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:17945 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755619Ab1EPOxU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 10:53:20 -0400
In-Reply-To: <20110516142340.GA2980@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-16 at 16:23 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Mon, May 16, 2011 at 02:37:46PM +0100, Ben Hutchings wrote:
> > On Mon, 2011-05-16 at 15:28 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> > > Remove NETIF_F_COMPAT since it's redundant and will be unused aft=
er
> > > all drivers are converted to fix/set_features.
> > >=20
> > > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl=
>
> > > ---
> > >=20
> > > For net as we don't want to have ETHTOOL_F_COMPAT hit stable rele=
ase.
> > [...]
> > ETHTOOL_F_WISH means that the requested features could not all be
> > enabled, *but are remembered*.  ETHTOOL_F_COMPAT means they were no=
t
> > remembered.
>=20
> Hmm. So, lets just revert 39fc0ce5710c53bad14aaba1a789eec810c556f9
> (net: Implement SFEATURES compatibility for not updated drivers).

That's also problematic because it means we can't make any use of the
'available' masks from ETHTOOL_GFEATURES.

The patch I sent is actually tested with a modified ethtool.  The
fallback works.  I don't think you've tested whether any of your
proposals can actually practically be used by ethtool.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

