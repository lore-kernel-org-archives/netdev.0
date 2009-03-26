From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: Re: [PATCH v3] net: Add support for the OpenCores 10/100 Mbps
	Ethernet MAC.
Date: Thu, 26 Mar 2009 09:09:59 +0100
Message-ID: <20090326080959.GA23013@avionic-design.de>
References: <20090325.171813.19940151.davem@davemloft.net> <1238053359-18896-1-git-send-email-thierry.reding@avionic-design.de> <20090326.005545.180326952.davem@davemloft.net> <20090326.005818.46327905.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:60667 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756659AbZCZIKA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 04:10:00 -0400
Content-Disposition: inline
In-Reply-To: <20090326.005818.46327905.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 26 Mar 2009 00:55:45 -0700 (PDT)
>=20
> > This doesn't build:
> >=20
> > drivers/net/ethoc.c: In function =E2=80=98ethoc_interrupt=E2=80=99:
> > drivers/net/ethoc.c:510: error: implicit declaration of function =E2=
=80=98netif_rx_schedule_prep=E2=80=99
> > drivers/net/ethoc.c:511: error: implicit declaration of function =E2=
=80=98__netif_rx_schedule=E2=80=99
> > drivers/net/ethoc.c: In function =E2=80=98ethoc_poll=E2=80=99:
> > drivers/net/ethoc.c:550: error: implicit declaration of function =E2=
=80=98netif_rx_complete=E2=80=99
> >=20
> > You are missing some header includes.
>=20
> Actually the problem is that you're using deprecated interfaces which
> have been removed in net-next-2.6, please use napi_*() instead of
> netif_rx_*().

Oh, okay. I've only been building against the vanilla tree. I'll grab a=
 copy
of net-next-2.6 and fix the driver up against that. Thanks,

Thierry

