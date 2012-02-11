From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Multiple GRE tunnels on the same host, only one routes incoming
 packets
Date: Sat, 11 Feb 2012 13:55:18 +0100
Message-ID: <1328964918.5661.26.camel@edumazet-laptop>
References: <201202111040.q1BAeESi014636@hope.more-right-rudder.com>
	 <1328959799.5661.25.camel@edumazet-laptop>
	 <201202111210.q1BCADqU026660@hope.more-right-rudder.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rick Koshi <netdev@more-right-rudder.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:42827 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754649Ab2BKMzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2012 07:55:25 -0500
Received: by wics10 with SMTP id s10so2588639wic.19
        for <netdev@vger.kernel.org>; Sat, 11 Feb 2012 04:55:24 -0800 (PST)
In-Reply-To: <201202111210.q1BCADqU026660@hope.more-right-rudder.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 11 f=C3=A9vrier 2012 =C3=A0 07:10 -0500, Rick Koshi a =C3=A9c=
rit :
> Eric Dumazet writes:
> >=20
> > check :
> >=20
> > grep . `find /proc/sys -name rp_filter`
>=20
> Thank you, thank you, thank you!  This is exactly right.
> CentOS by default sets reverse-path filtering (which I'd
> never even heard of before your message) partially on
> (value 1 in /proc/sys/net/ipv4/conf/default/rp_filter).
>=20
> In my case, I need it completely off for my 2 tunnel
> interfaces.  A quick change to my setup script, and
> everything works now.
>=20
> Thank you so very much.  You have saved me hours
> of frustration and given me a good night's sleep.  :-)
>=20

You're very welcome :)
