From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: limited network bandwidth with 3.2.x kernels
Date: Wed, 15 Feb 2012 09:31:51 +0100
Message-ID: <1329294711.2555.52.camel@edumazet-laptop>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	 <5133914.uYLb0gnNTc@localhost.localdomain>
	 <1329235210.4818.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <5781419.24ZaHfTAxC@localhost.localdomain>
	 <1329280993.2555.21.camel@edumazet-laptop>
	 <CADVnQykxiGBXCKdr=G+T190EA14RnAs0HJ69imsN0h8JKMS4jw@mail.gmail.com>
	 <1329286016.2555.41.camel@edumazet-laptop>
	 <20120215025200.6e6f02a2.billfink@mindspring.com>
	 <1329292820.2555.47.camel@edumazet-laptop>
	 <20120215031816.7afeef08.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>, alekcejk@googlemail.com,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44226 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757470Ab2BOIbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 03:31:55 -0500
Received: by wgbdt10 with SMTP id dt10so686585wgb.1
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 00:31:54 -0800 (PST)
In-Reply-To: <20120215031816.7afeef08.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 f=C3=A9vrier 2012 =C3=A0 03:18 -0500, Bill Fink a =C3=A9=
crit :

> Do your SYSCTL1 and SYSCTL2 files include /sys/module/tcp_*
> as well as /proc/sys?  Not that I know of anything that might
> have changed in /sys/module/tcp_* between 3.1 and 3.2, but
> you never know what a particular distro might have tweaked.
>=20


=46edora doesnt change these, and kernel version change is in TCP
receiver, where these congestion params dont apply.
