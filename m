From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] Phonet: remove dangling pipe if an
 endpoint is closed early
Date: Wed, 15 Sep 2010 21:32:58 -0700 (PDT)
Message-ID: <20100915.213258.212397416.davem@davemloft.net>
References: <1284589193-26089-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, remi.denis-courmont@nokia.com
To: remi@remlab.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50883
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750807Ab0IPEcj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Sep 2010 00:32:39 -0400
In-Reply-To: <1284589193-26089-1-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi@remlab.net>
Date: Thu, 16 Sep 2010 01:19:53 +0300

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> Closing a pipe endpoint is not normally allowed by the Phonet pipe,
> other than as a side after-effect of removing the pipe between two
> endpoints. But there is no way to prevent Linux userspace processes
> from being killed or suffering from bugs, so this can still happen.
> We might as well forcefully close Phonet pipe endpoints then.
>=20
> The cellular modem supports only a few existing pipes at a time. So w=
e
> really should not leak them. This change instructs the modem to destr=
oy
> the pipe if either of the pipe's endpoint (Linux socket) is closed to=
o
> early.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied.
