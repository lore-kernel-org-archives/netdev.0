From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: do not assume that template resolving always
 returns xfrms
Date: Wed, 14 Jul 2010 14:17:07 -0700 (PDT)
Message-ID: <20100714.141707.246527574.davem@davemloft.net>
References: <20100712.212041.236240543.davem@davemloft.net>
	<1279006182-11421-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux@horizon.com
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49181
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754050Ab0GNVQw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jul 2010 17:16:52 -0400
In-Reply-To: <1279006182-11421-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Tue, 13 Jul 2010 10:29:42 +0300

> xfrm_resolve_and_create_bundle() assumed that, if policies indicated
> presence of xfrms, bundle template resolution would always return
> some xfrms. This is not true for 'use' level policies which can
> result in no xfrm's being applied if there is no suitable xfrm states=
=2E
> This fixes a crash by this incorrect assumption.
>=20
> Reported-by: George Spelvin <linux@horizon.com>
> Bisected-by: George Spelvin <linux@horizon.com>
> Tested-by: George Spelvin <linux@horizon.com>
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>

Applied, thanks Timo.
