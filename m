From: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at skb_copy_and_csum_dev
Date: Fri, 20 Aug 2010 11:31:20 +0300
Message-ID: <4C6E3D58.5080303@fs.uni-ruse.bg>
References: <bug-16626-10286@https.bugzilla.kernel.org/>	 <20100819152143.8a57c465.akpm@linux-foundation.org>	 <4C6E0C99.2060407@fs.uni-ruse.bg>	 <20100819221142.b8f6a70a.akpm@linux-foundation.org>	 <4C6E1CBA.2060605@fs.uni-ruse.bg>	 <20100819232019.6f6074a8.akpm@linux-foundation.org>	 <4C6E202E.5030406@fs.uni-ruse.bg> <1282286070.2295.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [83.228.35.12] ([83.228.35.12]:34752 "EHLO fs.ru.acad.bg"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751866Ab0HTIbW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Aug 2010 04:31:22 -0400
In-Reply-To: <1282286070.2295.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=9D=D0=B0 20.8.2010 =D0=B3. 10:38, Plamen Petrov =D0=BD=D0=B0=D0=BF=D0=
=B8=D1=81=D0=B0:
> =D0=9D=D0=B0 20.8.2010 =D0=B3. 09:34, Eric Dumazet =D0=BD=D0=B0=D0=BF=
=D0=B8=D1=81=D0=B0:
>> > Le vendredi 20 ao=C3=BBt 2010 =C3=A0 09:26 +0300, Plamen Petrov a =
=C3=A9crit :
>>> >> Posting this only in the hope that it will be helpfull to the
>>> >> "net guys"...
>> >
=2E..
>> >
> But again, this is on 2.6.34.4. Could it be that
> "generic-receive-offload" is ON by default on my
> only gigabit capable tg3 card on 2.6.35.x and later?
>

Well, as it turns out - the commit enabling GRO for
tg3 cards was from the 2.6.35 merge window:
http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3Dcb903bf4ee2d6e53210e2174d363e10698112042

> tg3: Enable GRO by default.author	David S. Miller <davem@davemloft.ne=
t>=09
> 	Wed, 21 Apr 2010 01:49:45 +0000 (18:49 -0700)
> committer	David S. Miller <davem@davemloft.net>=09
> 	Wed, 21 Apr 2010 01:49:45 +0000 (18:49 -0700)
>
> This was merely an oversight when I added the *_gro_receive()
> calls.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

The next thing I will be trying is disabling
GRO for the tg3 network card in my network
startup scripts via my shiny new ethtool... ;)
