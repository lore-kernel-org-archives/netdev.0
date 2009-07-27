From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: net-next-2.6 phonet causes build error
Date: Mon, 27 Jul 2009 17:18:29 +0200
Message-ID: <1248707909.28545.200.camel@violet>
References: <4A6CA3BF.7010709@hartkopp.net>
	 <200907270927.55728.remi.denis-courmont@nokia.com>
	 <20090727.080158.118098654.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: remi.denis-courmont@nokia.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:55988 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634AbZG0PTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 11:19:33 -0400
In-Reply-To: <20090727.080158.118098654.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> >> net/phonet/pn_dev.c: In function =E2=80=98phonet_init_net=E2=80=99=
:
> >> net/phonet/pn_dev.c:221: error: implicit declaration of function
> >> =E2=80=98proc_net_fops_create=E2=80=99
> >> net/phonet/pn_dev.c: In function =E2=80=98phonet_exit_net=E2=80=99=
:
> >> net/phonet/pn_dev.c:242: error: implicit declaration of function
> >> =E2=80=98proc_net_remove=E2=80=99
> >=20
> > Oops. This makes me wonder why I did not get that one here on my te=
st=20
> > builds???
>=20
> Because the headers on your platform with your configuration end up
> including linux/proc_fs.h indirectly.

this and similar automatic includes on x86 are still a problem. I alway=
s
try to compile test with a PPC based system, but even that architecture
has a lot of indirect includes. I would be happy if we could get rid of
these for x86 systems, but that seems a little bit wishful thinking.

Regards

Marcel


