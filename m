From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: automatically enable stable privacy mode if
 stable_secret set
Date: Tue, 15 Dec 2015 23:38:04 -0500 (EST)
Message-ID: <20151215.233804.855487652290746503.davem@davemloft.net>
References: <1450216752-18088-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bjorn@mork.no
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56736 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbbLPEiG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 23:38:06 -0500
In-Reply-To: <1450216752-18088-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 15 Dec 2015 22:59:12 +0100

> Bj=F8rn reported that while we switch all interfaces to privacy stabl=
e mode
> when setting the secret, we don't set this mode for new interfaces. T=
his
> does not make sense, so change this behaviour.
>=20
> Fixes: 622c81d57b392cc ("ipv6: generation of stable privacy addresses=
 for link-local and autoconf")
> Reported-by: Bj=F8rn Mork <bjorn@mork.no>
> Cc: Bj=F8rn Mork <bjorn@mork.no>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Agreed, the current behavior makes no sense at all.

Applied and queued up for -stable, thanks.
