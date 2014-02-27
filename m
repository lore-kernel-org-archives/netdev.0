From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: addrconf: silence sparse endianness
 warnings
Date: Thu, 27 Feb 2014 17:13:39 -0500 (EST)
Message-ID: <20140227.171339.1719967390757385601.davem@davemloft.net>
References: <1393507229-14871-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49847 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbaB0WNm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 17:13:42 -0500
In-Reply-To: <1393507229-14871-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Thu, 27 Feb 2014 14:20:29 +0100

> Avoid the following sparse __CHECK_ENDIAN__ warnings:
>=20
>  include/net/addrconf.h:318:25: warning: restricted __be64 degrades t=
o integer
>  include/net/addrconf.h:318:70: warning: restricted __be64 degrades t=
o integer
>  include/net/addrconf.h:330:25: warning: restricted __be64 degrades t=
o integer
>  include/net/addrconf.h:330:70: warning: restricted __be64 degrades t=
o integer
>  include/net/addrconf.h:347:25: warning: restricted __be64 degrades t=
o integer
>  include/net/addrconf.h:348:26: warning: restricted __be64 degrades t=
o integer
>  include/net/addrconf.h:349:18: warning: restricted __be64 degrades t=
o integer
>=20
> The warnings are false but they make it harder to spot real
> bugs.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied, thank you.
