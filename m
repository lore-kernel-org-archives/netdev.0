From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool 2/3] ethtool: Regularise handling of offload
 flags
Date: Tue, 22 Feb 2011 16:44:33 +0000
Message-ID: <1298393073.14956.1.camel@bwh-desktop>
References: <1298307282.2608.47.camel@bwh-desktop>
	 <1298307548.2608.50.camel@bwh-desktop>
	 <20110222145004.GB25132@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:14991 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754006Ab1BVQog convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 11:44:36 -0500
In-Reply-To: <20110222145004.GB25132@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-02-22 at 15:50 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> On Mon, Feb 21, 2011 at 04:59:08PM +0000, Ben Hutchings wrote:
> > Use the new ETHTOOL_{G,S}FEATURES operations where available, and
> > use the new structure and netif feature flags in any case.
> >=20
> > Replace repetitive code for getting/setting offload flags with data=
-
> > driven loops.
> >=20
> > This changes error messages to use the same long names for offload
> > flags as in dump_offload(), and changes various exit codes to 1.
> >=20
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> > NEITF_F_* flags are copied into ethtool-util.h for now.  I think in
> > future they should be exposed from <linux/netdevice.h> (hence the
> > #ifndef).
>=20
> I tried to avoid making NETIF_F_ flags an ABI. That's why there's new
> ETH_SS_FEATURES ethtool string set. When bits in features get used up
> it might be desirable to reorder them while introducing a new field
> in struct net_device (eg. move non-changeable bits out of features).

The order is unimportant.  And feature flags are already exposed throug=
h
sysfs, so they are part of the kernel ABI.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

