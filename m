From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: Re: [PATCH] r6040 various bugfixes
Date: Thu, 15 Nov 2007 19:57:57 +0100
Message-ID: <200711151957.57708.florian.fainelli@telecomint.eu>
References: <200711151937.44681.florian.fainelli@telecomint.eu> <20071115105304.76ef6f29@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.int-evry.fr ([157.159.10.44]:37166 "EHLO
	smtp1.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760708AbXKOS6L convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 13:58:11 -0500
In-Reply-To: <20071115105304.76ef6f29@freepuppy.rosehill>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Stephen,

Le jeudi 15 novembre 2007, Stephen Hemminger a =E9crit=A0:
> Looks good, thanks:
>
> There is a function to make this easier:
> > @@ -756,10 +803,8 @@ r6040_open(struct net_device *dev)
> >  	if (lp->switch_sig !=3D ICPLUS_PHY_ID) {
> >  		/* set and active a timer process */
> >  		init_timer(&lp->timer);
> > -		lp->timer.expires =3D TIMER_WUT;
> >  		lp->timer.data =3D (unsigned long)dev;
> >  		lp->timer.function =3D &r6040_timer;
> > -		add_timer(&lp->timer);
>
> Could be:
> 	setup_timer(&lp->timer, r6040_timer, dev);
> 	if (lp->switch_sig !=3D ICPLUS_PHY_ID)
> 		mod_timer(&lp->timer, jiffies + HZ);

I will send a fix later when I have tested your suggestion to use sligh=
tly=20
larger buffer and skb_reserve(skb, NET_IP_ALIGN).

Thank you.
--=20
=46lorian
