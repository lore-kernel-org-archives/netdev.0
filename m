From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sysfs warnings, reserved names
Date: Fri, 17 Feb 2012 11:37:22 +0100
Message-ID: <1329475042.2861.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <41230e67c273dde6b60cfc7110f496e2@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:45413 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814Ab2BQKh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 05:37:26 -0500
Received: by wics10 with SMTP id s10so1445862wic.19
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2012 02:37:25 -0800 (PST)
In-Reply-To: <41230e67c273dde6b60cfc7110f496e2@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 f=C3=A9vrier 2012 =C3=A0 12:14 +0200, Denys Fedoryshchen=
ko a
=C3=A9crit :
> Hi
>=20
> Just did a test:
>=20
> ip link set dev eth1 name default
>=20
> And got a lot of (expected) sysfs warnings:
> [1068625.677143] sysctl table check failed:=20
> /net/ipv4/conf/default/promote_secondaries  Sysctl already exists
> [1068625.677151] Pid: 18106, comm: ip Not tainted 3.2.4-centaur #1
> and etc
>=20
> Kernel 3.2.4, but i guess it doesn't matter much.
> Maybe such names (as all and default) should be "reserved"?
> Or it is ok like that?
>=20

You're right, we should forbid this to happen.
