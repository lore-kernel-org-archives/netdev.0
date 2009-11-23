From: David Miller <davem@davemloft.net>
Subject: Re: [patch for 2.6.32? 2/2] hso: fix soft-lockup
Date: Mon, 23 Nov 2009 10:54:55 -0800 (PST)
Message-ID: <20091123.105455.153011323.davem@davemloft.net>
References: <200911172250.nAHMoW1k013162@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, antti.kaijanmaki@nomovok.com,
	greg@kroah.com, randy.dunlap@oracle.com, stable@kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41469
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752649AbZKWSyh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 13:54:37 -0500
In-Reply-To: <200911172250.nAHMoW1k013162@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: akpm@linux-foundation.org
Date: Tue, 17 Nov 2009 14:50:32 -0800

> From: Antti Kaijanm=E4ki <antti.kaijanmaki@nomovok.com>
>=20
> Fix soft-lockup in hso.c which is triggered on SMP machine when
> modem is removed while file descriptor(s) under /dev are still open:
>=20
>   old version called kref_put() too early which resulted in destroyin=
g
>   hso_serial and hso_device objects which were still used later on.
>=20
> Signed-off-by: Antti Kaijanm=E4ki <antti.kaijanmaki@nomovok.com>
> Cc: Greg KH <greg@kroah.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Randy Dunlap <randy.dunlap@oracle.com>
> Cc: <stable@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-2.6
