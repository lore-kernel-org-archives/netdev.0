From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: ping -I eth1 ....
Date: Fri, 5 Nov 2010 16:54:18 +0100
Message-ID: <OFAA7963DE.C3F04675-ONC12577D2.0056F55C-C12577D2.00575EC2@transmode.se>
References: <OF339BCA8A.B674D6AE-ONC12577D2.00481B5E-C12577D2.0048B214@transmode.se>	 <1288964206.2882.402.camel@edumazet-laptop>
	 <OF22F5901E.A7276220-ONC12577D2.004C79CB-C12577D2.004D1571@transmode.se>
	 <20101105142510.GA14986@canuck.infradead.org>	 <1288967665.2882.522.camel@edumazet-laptop>
	 <OF6C6C2970.245A64ED-ONC12577D2.00518CF6-C12577D2.00522AAD@transmode.se> <1288969614.2882.590.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@infradead.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:43117 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752280Ab0KEPyV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 11:54:21 -0400
In-Reply-To: <1288969614.2882.590.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote on 2010/11/05 16:06:54:
>
> Le vendredi 05 novembre 2010 =E0 15:57 +0100, Joakim Tjernlund a =E9c=
rit :
> > Eric Dumazet <eric.dumazet@gmail.com> wrote on 2010/11/05 15:34:25:
> > t be a reason why in many places we only test (dev->flags &
> > > IFF_UP), and _never_ netif_oper_up() (only in dev_get_flags() to =
export
> > > it at userspace)
> >
> > Hopefully most of that is legacy or just plain wrong? Unless
> > someone can say why only test IFF_UP one should consider changing t=
hem.
> >
>
> Most of the places are hot path.
>
> You dont want to replace one test by four tests.
>
> _This_ would be wrong :)

Wrong is wrong, even if it is in the hot path :)
Perhaps it is time define and internal IFF_OPERATIONAL flag
which is the sum of IFF_UP, IFF_RUNNING etc.? That
way you still get one test in the hot path and can abstract
what defines an operational link.

 Jocke

