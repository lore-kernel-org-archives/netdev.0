From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/5] net: ethtool: use ndo_fix_features for offload
 setting
Date: Mon, 07 Feb 2011 13:01:24 -0800 (PST)
Message-ID: <20110207.130124.189688858.davem@davemloft.net>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
	<ca3bcc3bec8779b67b476d5d7325ea9fbbf54308.1296741561.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38107
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754036Ab1BGVAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 16:00:49 -0500
In-Reply-To: <ca3bcc3bec8779b67b476d5d7325ea9fbbf54308.1296741561.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu,  3 Feb 2011 15:21:21 +0100 (CET)

> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>               =
                                    =20

Applied, and now I see why the tree "built" successfully for
you.

You remove the duplicate EXPORT_SYMBOL() in this patch.

You absolutely cannot test your patch sets like this, only
build testing at the end.

Every single individual change must not introduce any functional
or build regressions, therefore you must make sure the build works
fine after each and every patch in your series, not just after they
are all applied.

What disturbs me even more, is that really this problem was introduced
because you mixed functional and cleanup changes in the first patch.
Something you should also never do.
