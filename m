From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH ethtool 2/3] ethtool: Regularise handling of offload
	flags
Date: Tue, 22 Feb 2011 15:50:04 +0100
Message-ID: <20110222145004.GB25132@rere.qmqm.pl>
References: <1298307282.2608.47.camel@bwh-desktop> <1298307548.2608.50.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46006 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753890Ab1BVOuF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Feb 2011 09:50:05 -0500
Content-Disposition: inline
In-Reply-To: <1298307548.2608.50.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 21, 2011 at 04:59:08PM +0000, Ben Hutchings wrote:
> Use the new ETHTOOL_{G,S}FEATURES operations where available, and
> use the new structure and netif feature flags in any case.
>=20
> Replace repetitive code for getting/setting offload flags with data-
> driven loops.
>=20
> This changes error messages to use the same long names for offload
> flags as in dump_offload(), and changes various exit codes to 1.
>=20
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> NEITF_F_* flags are copied into ethtool-util.h for now.  I think in
> future they should be exposed from <linux/netdevice.h> (hence the
> #ifndef).

I tried to avoid making NETIF_F_ flags an ABI. That's why there's new
ETH_SS_FEATURES ethtool string set. When bits in features get used up
it might be desirable to reorder them while introducing a new field
in struct net_device (eg. move non-changeable bits out of features).

Best Regards,
Micha=B3 Miros=B3aw

