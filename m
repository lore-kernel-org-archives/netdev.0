From: Christian Kujau <evil@g-house.de>
Subject: Re: 2.6.7-rc3: waiting for eth0 to become free
Date: Thu, 10 Jun 2004 13:06:48 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <40C840C8.8000605@g-house.de>
References: <1086722310.1682.1.camel@teapot.felipe-alfaro.com>	 <20040608124215.291a7072@dell_ss3.pdx.osdl.net>	 <1086725369.1806.1.camel@teapot.felipe-alfaro.com>	 <20040608140200.2ddaa6f4@dell_ss3.pdx.osdl.net>	 <1086794282.1706.2.camel@teapot.felipe-alfaro.com>	 <40C793CE.6000609@g-house.de> <1086847636.1719.6.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev Mailinglist <netdev@oss.sgi.com>,
	Kernel Mailinglist <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S264398AbUFJLHE@vger.kernel.org>
To: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
In-Reply-To: <1086847636.1719.6.camel@teapot.felipe-alfaro.com>
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Felipe Alfaro Solana wrote:
| I think the mentioned error is not dependent on any specific interface
| (let it be eth0, or ppp0), but any interface in general which has a
| routing entry and is the target/source of IP traffic. This is based on
| the fact that my fixes play with the refcounting on any interface. not
| just eth0 specifically, and pertain to both IPv4 and IPv6 core.

ok.

| In my case, I was able to trigger the problem by running "cardctl eject"
| which was then stuck at D state. Killing any program using a network
| socket, and waiting for opened connections to transition from
| ESTABLISHED to TIME_WAIT and then being closed, allowed "cardctl" to
| exit the D state.

no having pcmcia here, i'll see if i can reproduce it to / see what the
patches will do.

Thanks for the explanation,
Christian.
- --
BOFH excuse #439:

Hot Java has gone cold
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFAyEDH+A7rjkF8z0wRAusDAKCp2WW4LO01hP9ZDXa3N6eH7cuvIgCg2dTz
IzprZryuJ/VuiRY/DGvMH24=
=f7qL
-----END PGP SIGNATURE-----
