From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-2.6] cxgb3: skb_record_rx_queue now records the
 queue index relative to the net_device.
Date: Fri, 24 Jun 2011 06:53:17 +0200
Message-ID: <1308891197.3000.2.camel@edumazet-laptop>
References: <20110624003912.14349.62988.stgit@speedy5.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, divy@chelsio.com,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: John Hernandez <jay@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53451 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506Ab1FXExW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 00:53:22 -0400
Received: by wyb38 with SMTP id 38so1681589wyb.19
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2011 21:53:20 -0700 (PDT)
In-Reply-To: <20110624003912.14349.62988.stgit@speedy5.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 23 juin 2011 =C3=A0 17:39 -0700, John Hernandez a =C3=A9crit :
> From: John (Jay) Hernandez <jay@chelsio.com>
>=20
> Fixed call to skb_record_rx_queue where we were passing the queue ind=
ex
> relative to the adapter when it should have been relative to the net_=
device.
>=20
> Signed-off-by: John (Jay) Hernandez <jay@chelsio.com>
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
>=20

Hmm, wasnt this bug reported by Shawn Bohrer ?

Reported-by: Shawn Bohrer <sbohrer@rgmadvisors.com>

Proper credits please ?

