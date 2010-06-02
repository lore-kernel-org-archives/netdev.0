From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 02 Jun 2010 18:33:59 +0200
Message-ID: <1275496439.2725.203.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1006021025200.30182@router.home>
	 <1275492754.2725.192.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1006021103410.30182@router.home>
	 <20100602.091909.113727983.davem@davemloft.net>
	 <alpine.DEB.2.00.1006021126500.30182@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:42252 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932745Ab0FBQeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 12:34:04 -0400
Received: by wwb28 with SMTP id 28so3041488wwb.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 09:34:02 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1006021126500.30182@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 juin 2010 =C3=A0 11:27 -0500, Christoph Lameter a =C3=A9=
crit :
> On Wed, 2 Jun 2010, David Miller wrote:
>=20
> > From: Christoph Lameter <cl@linux-foundation.org>
> > Date: Wed, 2 Jun 2010 11:12:14 -0500 (CDT)
> >
> > > Its important to know why drops occur (any drops for that matter,=
 drops
> > > mean retransmit which means latency).
> >
> > We know, that's why there is a networking tracepoint that allows yo=
u
> > to see where all drops occur. :-)
>=20
> Where can I find out more about the network tracepoint?
>=20

take a look at=20

http://www.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/html/SystemTa=
p_Beginners_Guide/useful-systemtap-scripts.html#dropwatch



