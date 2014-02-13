From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: explicitly include core.h in addr.h
Date: Thu, 13 Feb 2014 17:49:47 -0500 (EST)
Message-ID: <20140213.174947.1379285420118634060.davem@davemloft.net>
References: <1392194058-16271-1-git-send-email-andreas.bofjall@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	maloy@donjonn.com
To: andreas.bofjall@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045AbaBMWtt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:49:49 -0500
In-Reply-To: <1392194058-16271-1-git-send-email-andreas.bofjall@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: <andreas.bofjall@ericsson.com>
Date: Wed, 12 Feb 2014 09:34:18 +0100

> From: Andreas Bofj=E4ll <andreas.bofjall@ericsson.com>
>=20
> The inline functions in addr.h uses tipc_own_addr which is exported b=
y
> core.h, but addr.h never actually includes it. It works because it is
> explicitly included where this is used, but it looks a bit strange.
>=20
> Include core.h in addr.h explicitly to make the dependency clearer.
>=20
> Signed-off-by: Andreas Bofj=E4ll <andreas.bofjall@ericsson.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thank you.
