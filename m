From: Thomas Graf <tgraf@suug.ch>
Subject: Re: tcp crash in net-2.6 tree
Date: Mon, 2 Apr 2007 23:06:01 +0200
Message-ID: <20070402210601.GS521@postel.suug.ch>
References: <mFVio6um.1175336346.4693300.ijjarvin@cs.helsinki.fi> <Pine.LNX.4.64.0704021133220.28337@kivilampi-30.cs.helsinki.fi> <20070402.020232.25465868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:41058 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965858AbXDBVFl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2007 17:05:41 -0400
Content-Disposition: inline
In-Reply-To: <20070402.020232.25465868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> 2007-04-02 02:02
> From: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 2 Apr 2007 11:38:51 +0300 (EEST)
>=20
> > [PATCH] [TCP]: Fix invalid skb referencing in LOST marker code
> >=20
> > The after() referenced an invalid skb if loop exited when skb had
> > reached sk_write_queue. I chose to move this part inside the loop
> > where the skb is valid (so no need to check for that like I first
> > suggested), which also allows dropping of couple of conditions
> > from the if.
> >=20
> > Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> Patch applied, thanks a lot Ilpo.

I can no longer trigger the bug, thanks Ilpo.
