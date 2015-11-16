From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fix __netdev_update_features return on
 ndo_set_features failure
Date: Mon, 16 Nov 2015 14:56:40 -0500 (EST)
Message-ID: <20151116.145640.946535191930162699.davem@davemloft.net>
References: <1447424424-4419-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
	mirq-linux@rere.qmqm.pl
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40503 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746AbbKPT4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 14:56:42 -0500
In-Reply-To: <1447424424-4419-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nikolay Aleksandrov <razor@blackwall.org>
Date: Fri, 13 Nov 2015 15:20:24 +0100

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>=20
> If ndo_set_features fails __netdev_update_features() will return -1 b=
ut
> this is wrong because it is expected to return 0 if no features were
> changed (see netdev_update_features()), which will cause a netdev
> notifier to be called without any actual changes. Fix this by returni=
ng
> 0 if ndo_set_features fails.
>=20
> Fixes: 6cb6a27c45ce ("net: Call netdev_features_change() from netdev_=
update_features()")
> CC: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied.
