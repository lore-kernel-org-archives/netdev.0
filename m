From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH ethtool 2/3] ethtool: Regularise handling of offload
	flags
Date: Tue, 22 Feb 2011 18:03:26 +0100
Message-ID: <20110222170326.GA10540@rere.qmqm.pl>
References: <1298307282.2608.47.camel@bwh-desktop> <1298307548.2608.50.camel@bwh-desktop> <20110222145004.GB25132@rere.qmqm.pl> <1298393073.14956.1.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:44437 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750734Ab1BVRDa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Feb 2011 12:03:30 -0500
Content-Disposition: inline
In-Reply-To: <1298393073.14956.1.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 22, 2011 at 04:44:33PM +0000, Ben Hutchings wrote:
> On Tue, 2011-02-22 at 15:50 +0100, Micha=B3 Miros=B3aw wrote:
> > On Mon, Feb 21, 2011 at 04:59:08PM +0000, Ben Hutchings wrote:
> > > Use the new ETHTOOL_{G,S}FEATURES operations where available, and
> > > use the new structure and netif feature flags in any case.
> > >=20
> > > Replace repetitive code for getting/setting offload flags with da=
ta-
> > > driven loops.
> > >=20
> > > This changes error messages to use the same long names for offloa=
d
> > > flags as in dump_offload(), and changes various exit codes to 1.
> > >=20
> > > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > > ---
> > > NEITF_F_* flags are copied into ethtool-util.h for now.  I think =
in
> > > future they should be exposed from <linux/netdevice.h> (hence the
> > > #ifndef).
> > I tried to avoid making NETIF_F_ flags an ABI. That's why there's n=
ew
> > ETH_SS_FEATURES ethtool string set. When bits in features get used =
up
> > it might be desirable to reorder them while introducing a new field
> > in struct net_device (eg. move non-changeable bits out of features)=
=2E
> The order is unimportant.  And feature flags are already exposed thro=
ugh
> sysfs, so they are part of the kernel ABI.

Since NETIF_F flags are not exposed in the headers I would assume that
/sys/class/net/*/features is a debugging aid and not part of an ABI.
(And I think that's good.)

Best Regards,
Micha=B3 Miros=B3aw
