From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v2 03/16] net: reduce and unify printk level in
	netdev_fix_features()
Date: Sun, 23 Jan 2011 00:48:28 +0100
Message-ID: <20110122234828.GB30734@rere.qmqm.pl>
References: <cover.1295734270.git.mirq-linux@rere.qmqm.pl> <29e476c368b6580f7ff5215ca759b69c75d0e021.1295734271.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Joe Perches <joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:40288 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751102Ab1AVXs3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jan 2011 18:48:29 -0500
Content-Disposition: inline
In-Reply-To: <29e476c368b6580f7ff5215ca759b69c75d0e021.1295734271.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 22, 2011 at 11:14:12PM +0100, Micha=B3 Miros=B3aw wrote:
> Reduce printk() levels to KERN_INFO in netdev_fix_features() as this =
will
> be used by ethtool and might spam dmesg unnecessarily.
>=20
> This converts the function to use netdev_info() instead of plain prin=
tk().
>=20
> As a side effect, bonding and bridge devices will now log dropped fea=
tures
> on every slave device change.

Hmm. I wonder whether it would be better to demote it further to KERN_D=
EBUG?
With the new interface, user could see when and which features are requ=
ested
but not active and figure the rest from documentation. Currently, disab=
ling
of features because of other (temporary) conditions is not logged anywa=
y.

Best Regards,
Micha=B3 Miros=B3aw
