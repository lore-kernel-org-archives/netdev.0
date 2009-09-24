From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Phonet: fix race for port number in concurrent bind()
Date: Thu, 24 Sep 2009 15:45:18 -0700 (PDT)
Message-ID: <20090924.154518.22801160.davem@davemloft.net>
References: <1253711831-7947-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, remi.denis-courmont@nokia.com
To: remi@remlab.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33055
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752043AbZIXWo7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2009 18:44:59 -0400
In-Reply-To: <1253711831-7947-1-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi@remlab.net>
Date: Wed, 23 Sep 2009 16:17:10 +0300

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> Allocating a port number to a socket and hashing that socket shall be
> an atomic operation with regards to other port allocation. Otherwise,
> we could allocate a port that is already being allocated to another
> socket.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied.
