From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: Bonding problem
Date: Mon, 8 Aug 2011 12:26:45 -0400
Message-ID: <20110808162645.GT21309@gospo.rdu.redhat.com>
References: <CANMAZFUibmkyfWP2TyjwV6wtox6LNry2Gh3AtXB2KHnhGF80rQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: majordomo@vger.kernel.org, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Eduard Sinelnikov <eduard.sinelnikov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16765 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753114Ab1HHQ0v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2011 12:26:51 -0400
Content-Disposition: inline
In-Reply-To: <CANMAZFUibmkyfWP2TyjwV6wtox6LNry2Gh3AtXB2KHnhGF80rQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 07, 2011 at 03:00:30PM +0300, Eduard Sinelnikov wrote:
> Hi,
>=20
> In the kernel 2.6.39.3 ( /drivers/net/bond/bond_main.c).
> In the function =C2=A0=E2=80=98bond_xmit_roundrobin=E2=80=99
> The code check if the bond is active via
> =E2=80=98bond_is_active_slave(slave)=E2=80=99 Function call.
> Which actually checks if the slave is backup or active
> What is the meaning of slave being =C2=A0backup in round robin mode?
> Correct me if I wrong but in round robin every slave should send a
> packet, regardless of being active or backup.
>=20
> Thank you,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Eduard

There probably is not a compelling reason to continue to have it.  Ther=
e
may be a reason historically, but I'm not aware what that might be at
this point.  For modes other than active-backup, the value of
slave->link and slave->backup should always contain a value that
indicates the slave is up and available for transmit.

