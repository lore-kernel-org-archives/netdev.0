From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] mlx4_en: TX ring size default to 1024
Date: Thu, 23 Feb 2012 20:54:04 +0100
Message-ID: <1330026844.15610.37.camel@edumazet-laptop>
References: <4F46404D.10509@mellanox.co.il>
	 <20120223.144541.1354349294973443529.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yevgenyp@mellanox.co.il, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:53120 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753246Ab2BWTyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 14:54:12 -0500
Received: by werb13 with SMTP id b13so1001807wer.19
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2012 11:54:11 -0800 (PST)
In-Reply-To: <20120223.144541.1354349294973443529.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 23 f=C3=A9vrier 2012 =C3=A0 14:45 -0500, David Miller a =C3=A9=
crit :
> From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> Date: Thu, 23 Feb 2012 15:34:05 +0200
>=20
> > Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
>=20
> This is rediculious as a default, yes even for 10Gb.
>=20
> Do you have any idea how high latency is going to be for packets
> trying to get into the transmit queue if there are already a
> thousand other frames in there?

Before increasing TX ring sizes, a driver should implement BQL as a
prereq.
