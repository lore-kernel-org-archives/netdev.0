From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
Date: Mon, 26 Jul 2010 22:39:03 +0200
Message-ID: <1280176743.2531.4.camel@edumazet-laptop>
References: <1279700420.2452.15.camel@edumazet-laptop>
	 <1279701835.2452.17.camel@edumazet-laptop>
	 <20100725.215548.112589000.davem@davemloft.net>
	 <20100726.130821.179918086.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51132 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330Ab0GZUjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 16:39:09 -0400
Received: by wwj40 with SMTP id 40so605799wwj.1
        for <netdev@vger.kernel.org>; Mon, 26 Jul 2010 13:39:06 -0700 (PDT)
In-Reply-To: <20100726.130821.179918086.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 26 juillet 2010 =C3=A0 13:08 -0700, David Miller a =C3=A9crit =
:

> I bet you didn't compile test the code you modified at all, but it's
> not your fault :-)
>=20
> The code is protected by CONFIG_WIRELESS_EXT but that protection is
> not valid.  It should be protected by something like CONFIG_WEXT_CORE
> or similar.
>=20
> The only way to get CONFIG_WIRELESS_EXT set it to enable one of a few
> drivers, many of which are in staging.
>=20
> Anyways, just a heads up, I'll fix this up.

Well, I recall having compiled (but not boot tested) patches,
on my x86_64 dev machine with a .config containing :

# grep WIRELESS_EXT .config
CONFIG_WIRELESS_EXT=3Dy
CONFIG_WIRELESS_EXT_SYSFS=3Dy
# grep COMPAT_NETLINK_MESSAGES .config
CONFIG_COMPAT_NETLINK_MESSAGES=3Dy

Cannot remember if I compiled v3 of the patch, to be honest.

Thanks


