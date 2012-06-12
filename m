From: Ben Hutchings <bhutchings@solarflare.com>
Subject: ethtool: allow ETHTOOL_GSSET_INFO for users
Date: Wed, 13 Jun 2012 00:27:58 +0100
Message-ID: <1339543678.15266.7.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35474 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752110Ab2FLX2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 19:28:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please consider this for stable 3.0.y and 3.2.y:

commit f80400a26a2e8bff541de12834a1134358bb6642
Author: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Date:   Sun Jan 22 00:20:40 2012 +0000

    ethtool: allow ETHTOOL_GSSET_INFO for users
   =20
    Allow ETHTOOL_GSSET_INFO ethtool ioctl() for unprivileged users.
    ETHTOOL_GSTRINGS is already allowed, but is unusable without this o=
ne.
   =20
    Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
    Acked-by: Ben Hutchings <bhutchings@solarflare.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
