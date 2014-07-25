From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: net, phonet, rcu: rcu hang within =?UTF-8?Q?gprs=5Fattach?=
Date: Fri, 25 Jul 2014 10:43:46 +0300
Message-ID: <8427f661d1aa5707ee18596e812fd3c5@roundcube.remlab.net>
References: <53D1865F.7040604@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns207790.ip-94-23-215.eu ([94.23.215.26]:50675 "EHLO
	ns207790.ip-94-23-215.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756732AbaGYHnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 03:43:49 -0400
In-Reply-To: <53D1865F.7040604@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    Hello,

Le 2014-07-25 01:19, Sasha Levin a =C3=A9crit=C2=A0:
> This has reproduced couple of times, and has always originated from
> gprs_attach. I don't see any obvious
> issues with the code there, so I'm not sure if it's a fault of the
> phonet or the rcu code.

Beats me :-( Is it systematic or pseudo-random?

To be honest, I do not remember how well we tested that error path way=20
back when. Nevertheless gprs_detach() does basically the same thing, in=
=20
the non-error case, and it definitely worked well as far as I could=20
tell.

Maybe Phonet should be dropped though. As much as I like to have my=20
name in MAINTAINERS, I have not heard of any remaining users for=20
up-to-date kernel versions. And with Broadcom shutting down what was=20
Nokia Wireless Modems, I doubt we will see new users ever.

--=20
R=C3=A9mi Denis-Courmont
