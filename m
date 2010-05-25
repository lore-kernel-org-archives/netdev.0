From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Phonet: fix potential use-after-free in
 pep_sock_close()
Date: Tue, 25 May 2010 16:08:50 -0700 (PDT)
Message-ID: <20100525.160850.193716383.davem@davemloft.net>
References: <1274796709-29988-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41976
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751481Ab0EYXIl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 May 2010 19:08:41 -0400
In-Reply-To: <1274796709-29988-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Tue, 25 May 2010 17:11:49 +0300

> sk_common_release() might destroy our last reference to the socket.
> So an extra temporary reference is needed during cleanup.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Patch applied, thank you.
