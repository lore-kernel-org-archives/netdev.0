From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH net-2.6] ethtool: Remove fallback to old ethtool
 operations for ETHTOOL_SFEATURES
Date: Sat, 14 May 2011 12:35:39 +0200
Message-ID: <20110514103539.GA5214@rere.qmqm.pl>
References: <1305335142.2851.70.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50844 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753462Ab1ENKfk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 06:35:40 -0400
Content-Disposition: inline
In-Reply-To: <1305335142.2851.70.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 14, 2011 at 02:05:42AM +0100, Ben Hutchings wrote:
> ethtool_set_feature_compat() squashes the feature mask into a boolean=
,
> which is not correct for ethtool_ops::set_flags.
>=20
> We could fix this, but the fallback code for ETHTOOL_SFEATURES actual=
ly
> makes things more complicated for the ethtool utility and any other
> application using the ethtool API.  They will still need to fall back=
 to
> the old offload control commands in order to support older kernel
> versions.  The fallback code in the kernel adds a third possibility f=
or
> them to handle.  So make ETHTOOL_SFEATURES fail when the driver
> implements the old offload control operations, and let userland do th=
e
> fallback.

BTW, the idea behind the compat code is that if ETHTOOL_[GS]FEATURES is
available, then there should be no need to fallback to old ops. For
a userspace tool that targets only kernels >=3D 2.6.39 there's no need
to care about old ops at all.

Best Regards,
Micha=B3 Miros=B3aw
