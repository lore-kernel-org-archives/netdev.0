From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/core: revert "net: fix
 __netdev_update_features return.." and add comment
Date: Tue, 17 Nov 2015 15:27:23 -0500 (EST)
Message-ID: <20151117.152723.1710661109450916935.davem@davemloft.net>
References: <564B3A3E.50905@cumulusnetworks.com>
	<1447771746-17943-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
	mirq-linux@rere.qmqm.pl
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60005 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705AbbKQU1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 15:27:25 -0500
In-Reply-To: <1447771746-17943-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nikolay Aleksandrov <razor@blackwall.org>
Date: Tue, 17 Nov 2015 15:49:06 +0100

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>=20
> This reverts commit 00ee59271777 ("net: fix __netdev_update_features =
return
> on ndo_set_features failure")
> and adds a comment explaining why it's okay to return a value other t=
han
> 0 upon error. Some drivers might actually change flags and return an
> error so it's better to fire a spurious notification rather than miss
> these.
>=20
> CC: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> Thanks to Michal for the explanation on why it was made to act like t=
hat.
> Also sorry for the noise, unfortunately I missed this. IMO this shoul=
d've
> been an all or nothing op from the beginning.

Applied.
