From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] sh_eth: coding style fixes
Date: Thu, 02 Jan 2014 17:42:27 -0800
Message-ID: <1388713347.2259.86.camel@joe-AO722>
References: <201312310325.21951.sergei.shtylyov@cogentembedded.com>
	 <20140102.193407.23280653408847634.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0162.hostedemail.com ([216.40.44.162]:58974 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751862AbaACBmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 20:42:36 -0500
In-Reply-To: <20140102.193407.23280653408847634.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 19:34 -0500, David Miller wrote:
> From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Date: Tue, 31 Dec 2013 03:25:21 +0300
>=20
> > @@ -1952,8 +1949,8 @@ static void sh_eth_tx_timeout(struct net
> >  	netif_stop_queue(ndev);
> > =20
> >  	if (netif_msg_timer(mdp))
> > -		dev_err(&ndev->dev, "%s: transmit timed out, status %8.8x,"
> > -	       " resetting...\n", ndev->name, (int)sh_eth_read(ndev, EESR=
));
> > +		dev_err(&ndev->dev, "%s: transmit timed out, status %8.8x, reset=
ting...\n"
> > +			ndev->name, (int)sh_eth_read(ndev, EESR));
> > =20
> >  	/* tx_errors count up */
> >  	ndev->stats.tx_errors++;
>=20
> You did not build test this.
>=20
> drivers/net/ethernet/renesas/sh_eth.c: In function =E2=80=98sh_eth_tx=
_timeout=E2=80=99:
> drivers/net/ethernet/renesas/sh_eth.c:1953:4: error: expected =E2=80=98=
)=E2=80=99 before =E2=80=98ndev=E2=80=99

Also, this would likely be better as:

	netif_err(mdp, timer, ndev, "transmit timed out, status %#08lx, resett=
ing...\n",
		  sh_eth_read(ndev, EESR));
