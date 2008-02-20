From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bonding: simplify code and get rid of warning
Date: Wed, 20 Feb 2008 09:24:30 -0800
Message-ID: <20080220092430.623b640f@extreme>
References: <20080218210426.022bbe36@extreme>
	<21522.1203526676@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:35207 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753075AbYBTRYg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 12:24:36 -0500
In-Reply-To: <21522.1203526676@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Feb 2008 08:57:56 -0800
Jay Vosburgh <fubar@us.ibm.com> wrote:

> Stephen Hemminger <shemminger@vyatta.com> wrote:
>=20
> >Get rid of warning and simplify code that looks up vlan tag.
> >No need to get tag, then copy it. Also no need for a local status
> >variable.
>=20
> 	Granted, the current code is suboptimal, but I don't see any
> warnings compiling this (gcc 4.1.2).  What are you getting?
>=20

Gcc 4.2.3
  CC [M]  drivers/net/bonding/bond_main.o
drivers/net/bonding/bond_main.c: In function =E2=80=98bond_dev_queue_xm=
it=E2=80=99:
drivers/net/bonding/bond_main.c:386: warning: =E2=80=98vlan_id=E2=80=99=
 may be used uninitialized in this function
  CC [M]  drivers/net/bonding/bond_3ad.o
  CC [M]  drivers/net/bonding/bond_alb.o
drivers/net/bonding/bond_alb.c: In function =E2=80=98rlb_choose_channel=
=E2=80=99:
drivers/net/bonding/bond_alb.c:681: warning: =E2=80=98vlan_id=E2=80=99 =
may be used uninitialized in this function
  CC [M]  drivers/net/bonding/bond_sysfs.o
