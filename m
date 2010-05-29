From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] Phonet: listening socket lock protects the
 connected socket list
Date: Sat, 29 May 2010 00:20:02 -0700 (PDT)
Message-ID: <20100529.002002.220041357.davem@davemloft.net>
References: <1274870684-18428-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38362
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754785Ab0E2HTw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 May 2010 03:19:52 -0400
In-Reply-To: <1274870684-18428-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Wed, 26 May 2010 13:44:44 +0300

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> The accept()'d socket need to be unhashed while the (listen()'ing)
> socket lock is held. This fixes a race condition that could lead to a=
n
> OOPS.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied.
