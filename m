From: David Miller <davem@davemloft.net>
Subject: Re: tcp crash in net-2.6 tree
Date: Mon, 02 Apr 2007 02:02:32 -0700 (PDT)
Message-ID: <20070402.020232.25465868.davem@davemloft.net>
References: <mFVio6um.1175336346.4693300.ijjarvin@cs.helsinki.fi>
	<Pine.LNX.4.64.0704021133220.28337@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, tgraf@suug.ch, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53233
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753426AbXDBJCd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2007 05:02:33 -0400
In-Reply-To: <Pine.LNX.4.64.0704021133220.28337@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 2 Apr 2007 11:38:51 +0300 (EEST)

> [PATCH] [TCP]: Fix invalid skb referencing in LOST marker code
>=20
> The after() referenced an invalid skb if loop exited when skb had
> reached sk_write_queue. I chose to move this part inside the loop
> where the skb is valid (so no need to check for that like I first
> suggested), which also allows dropping of couple of conditions
> from the if.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Patch applied, thanks a lot Ilpo.
