From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: net-next-2.6 phonet causes build error
Date: Mon, 27 Jul 2009 17:30:12 +0200
Message-ID: <4A6DC804.4010803@hartkopp.net>
References: <4A6CA3BF.7010709@hartkopp.net>	 <200907270927.55728.remi.denis-courmont@nokia.com>	 <20090727.080158.118098654.davem@davemloft.net> <1248707909.28545.200.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, remi.denis-courmont@nokia.com,
	netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:18069 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484AbZG0PaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 11:30:14 -0400
In-Reply-To: <1248707909.28545.200.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcel Holtmann wrote:
> Hi Dave,
>=20
>>>> net/phonet/pn_dev.c: In function =E2=80=98phonet_init_net=E2=80=99=
:
>>>> net/phonet/pn_dev.c:221: error: implicit declaration of function
>>>> =E2=80=98proc_net_fops_create=E2=80=99
>>>> net/phonet/pn_dev.c: In function =E2=80=98phonet_exit_net=E2=80=99=
:
>>>> net/phonet/pn_dev.c:242: error: implicit declaration of function
>>>> =E2=80=98proc_net_remove=E2=80=99
>>> Oops. This makes me wonder why I did not get that one here on my te=
st=20
>>> builds???
>> Because the headers on your platform with your configuration end up
>> including linux/proc_fs.h indirectly.
>=20
> this and similar automatic includes on x86 are still a problem. I alw=
ays
> try to compile test with a PPC based system, but even that architectu=
re
> has a lot of indirect includes. I would be happy if we could get rid =
of
> these for x86 systems, but that seems a little bit wishful thinking.
>=20

I second this. But in this special case i was using a x86 architecture,=
 that
behaved correct.

Maybe one of the script wizards has an idea how to identify and /probab=
ly/ fix
these automatic includes ...

Regards,
Oliver

