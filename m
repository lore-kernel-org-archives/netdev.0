From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v5 7/9] ethtool: prepare for larger netdev_features_t
 type
Date: Thu, 17 Nov 2011 00:18:51 +0100
Message-ID: <20111116231851.GA8476@rere.qmqm.pl>
References: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
 <77229786587ed90001dfee923c1d7794b758e3e1.1321404954.git.mirq-linux@rere.qmqm.pl>
 <1321483409.2709.31.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:52220 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754225Ab1KPXSy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 18:18:54 -0500
Content-Disposition: inline
In-Reply-To: <1321483409.2709.31.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2011 at 10:43:29PM +0000, Ben Hutchings wrote:
> On Wed, 2011-11-16 at 02:29 +0100, Micha=B3 Miros=B3aw wrote:
> > v2:	changed loop in ethtool_set_features() per Ben's suggestion
> >=20
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Run checkpatch and fix the spacing complaints.  After that, consider
> this:

There are two lines longer than 80 chars, but it won't improve readabil=
ity
if I split them. No spacing complaints on my run of checkpatch:

WARNING: line over 80 characters
#51: FILE: net/core/ethtool.c:91:
+       BUILD_BUG_ON(ETHTOOL_DEV_FEATURE_WORDS*sizeof(u32) > sizeof(net=
dev_features_t));

WARNING: line over 80 characters
#57: FILE: net/core/ethtool.c:97:
+               features[i].never_changed =3D (u32)(NETIF_F_NEVER_CHANG=
E >> (32*i));

total: 0 errors, 2 warnings, 75 lines checked

/tmp/0007-ethtool-prepare-for-larger-netdev_features_t-type.patch has s=
tyle problems, please review.

Best Regards,
Micha=B3 Miros=B3aw
