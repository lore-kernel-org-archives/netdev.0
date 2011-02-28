From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/2] be2net: remove netif_stop_queue being
 called before register_netdev.
Date: Sun, 27 Feb 2011 16:07:02 -0800 (PST)
Message-ID: <20110227.160702.229751524.davem@davemloft.net>
References: <20110131232755.GA4691@akhaparde-VBox>
	<20110201.154209.179944086.davem@davemloft.net>
	<1298560543.2814.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ajit.khaparde@emulex.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40047
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751833Ab1B1AG0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Feb 2011 19:06:26 -0500
In-Reply-To: <1298560543.2814.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 Feb 2011 16:15:43 +0100

> Le mardi 01 f=E9vrier 2011 =E0 15:42 -0800, David Miller a =E9crit :
>> From: Ajit Khaparde <ajit.khaparde@emulex.com>
>> Date: Mon, 31 Jan 2011 17:27:55 -0600
>>=20
>> > It is illegal to call netif_stop_queue before register_netdev.
>> >=20
>> > Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
>>=20
>> Applied, thanks.
>=20
> Not sure if this patch is queued for stable, I hit the bug (a Warning
> actually) on 2.6.37.1

I've added this to my -stable queue, thanks.
