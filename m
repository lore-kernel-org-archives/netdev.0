From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ixgbe->bonding->vlan->bridge->ebtables&iptables causes memory
 corruption
Date: Tue, 27 Jul 2010 16:31:17 +0200
Message-ID: <1280241077.2827.327.camel@edumazet-laptop>
References: <AANLkTimEYWiz4d-go6PszKnR0U29FYfjvHeLbPavi-RH@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Gyorgy Jeney <nog.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35794 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005Ab0G0ObW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 10:31:22 -0400
In-Reply-To: <AANLkTimEYWiz4d-go6PszKnR0U29FYfjvHeLbPavi-RH@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 juillet 2010 =C3=A0 09:15 +0200, Gyorgy Jeney a =C3=A9crit =
:
> Hi,
>=20
> I  have a rather interesting network setup here.  First I have a dual
> 10Gbit ixgbe ethernet card, being bonded into one link, on which we
> run a number of vlans, which are bridged with various virtual
> machines.  Now, to protect the box itself and the virtual machines I
> have a set of iptables and ebtables rules.  Whenever one of the
> virtual machines start the kernel, which is 2.6.35-rc6, will reliably
> panic.
>=20
> This error needs both ebtables and iptables rules, without either one
> or the other, things seem to work quite well.
>=20
> The errors and backtraces are many and long, so I attached the full
> dmes output, please say if you need more.
>=20
> nog.

Not related to your crashes, but I wonder how
net/bridge/netfilter/ebt_vlan.c is supposed to work with hw accelerated
vlans...



