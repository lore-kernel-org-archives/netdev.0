From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP] Highspeed: Limited slow-start is nowadays in
 tcp_slow_start
Date: Thu, 03 May 2007 13:29:09 -0700 (PDT)
Message-ID: <20070503.132909.93447193.davem@davemloft.net>
References: <Pine.LNX.4.64.0705031531170.3607@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42750
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031206AbXECU3I convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 16:29:08 -0400
In-Reply-To: <Pine.LNX.4.64.0705031531170.3607@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 3 May 2007 15:34:25 +0300 (EEST)

> Reuse limited slow-start (RFC3742) included into tcp_cong instead
> of having another implementation in High Speed TCP.
>=20
> Compile tested only.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Thanks for noticing this code duplication.

I've applied this, but it would be great if someone would
do some sanity tests of highspeed to make sure it's
ok.
