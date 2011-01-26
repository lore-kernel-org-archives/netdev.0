From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 40k+ outbound connections and bind() problem
Date: Wed, 26 Jan 2011 14:17:14 +0100
Message-ID: <1296047834.2899.62.camel@edumazet-laptop>
References: <8cdb2dde69120a8668b31e2050916493@visp.net.lb>
	 <AANLkTikSvf8bNK2_eHg+cWQJLz-56_88mrf0ttJX3W=0@mail.gmail.com>
	 <9e62acde19ef75f3f77468cd81ed7ffd@visp.net.lb>
	 <AANLkTinDQ-n3Y2_8PtvdWSxkYV8Kvj8on3iEeHsBSFB-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: Daniel Baluta <daniel.baluta@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55912 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421Ab1AZNRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 08:17:19 -0500
Received: by wyb28 with SMTP id 28so901715wyb.19
        for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 05:17:18 -0800 (PST)
In-Reply-To: <AANLkTinDQ-n3Y2_8PtvdWSxkYV8Kvj8on3iEeHsBSFB-@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 26 janvier 2011 =C3=A0 15:00 +0200, Daniel Baluta a =C3=A9c=
rit :
> Hi,
>=20
> > Latest stable, 2.6.37
>=20
> Please apply this patch [1] and see if it's still happening.
>=20
> thanks,
> Daniel
>=20
> [1] http://www.spinics.net/lists/netdev/msg152204.html
> -

I dont think it'll help ;)

Denys problem is if one source IP address is used, there is an absolute
64K limit to (IP, port) tuple

Only thing you can do is to tune /proc/sys/net/ipv4/ip_local_port_range
to get close to 64K limit



