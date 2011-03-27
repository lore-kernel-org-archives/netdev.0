From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Subject: Re: disabling ipv6 (when ipv6 module is already loaded or built in)
Date: Sun, 27 Mar 2011 23:19:15 +0200
Message-ID: <201103272319.16022.a.miskiewicz@gmail.com>
References: <201103251817.04583.a.miskiewicz@gmail.com> <201103252353.06297.a.miskiewicz@gmail.com> <20110325.155657.193733904.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:40628 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960Ab1C0VTW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 17:19:22 -0400
Received: by ewy4 with SMTP id 4so1012255ewy.19
        for <netdev@vger.kernel.org>; Sun, 27 Mar 2011 14:19:21 -0700 (PDT)
In-Reply-To: <20110325.155657.193733904.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 25 of March 2011, David Miller wrote:
> From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
> Date: Fri, 25 Mar 2011 23:53:06 +0100
>=20
> > The whole problem is that socket(AF_INET6,...) is allowed. If setti=
ng
> > net.ipv6.conf.all.disable_ipv6=3D1 would also prevent such socket()=
 from
> > succeeding then everything would be fine.
>=20
> You have to make this setting before the module loads, once we regist=
er
> the protocol handlers (which is what allows socket() to succeed) the
> cat is out of the bag.
>=20
> If even just one socket exists, we can't perform the steps necessary
> to block new ones.
>=20
> That's why you have to use the module option, and it is the only way
> to block this class of operations.

Hm, maybe then it could be done in a way where ipv6 is initially built =
in but=20
disabled and could be permanently enabled via sysfs/proc/something base=
d on a=20
userspace (or user/admin) decision runtime? That would be analogous to=20
"modprobe ipv6" in kernel with modular ipv6.

--=20
Arkadiusz Mi=C5=9Bkiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
