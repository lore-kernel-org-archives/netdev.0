From: Christian Kujau <evil@g-house.de>
Subject: Re: 2.6.7-rc3: waiting for eth0 to become free
Date: Thu, 10 Jun 2004 00:48:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40C793CE.6000609@g-house.de>
References: <1086722310.1682.1.camel@teapot.felipe-alfaro.com>	 <20040608124215.291a7072@dell_ss3.pdx.osdl.net>	 <1086725369.1806.1.camel@teapot.felipe-alfaro.com>	 <20040608140200.2ddaa6f4@dell_ss3.pdx.osdl.net> <1086794282.1706.2.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev Mailinglist <netdev@oss.sgi.com>,
        Kernel Mailinglist <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
In-Reply-To: <1086794282.1706.2.camel@teapot.felipe-alfaro.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Felipe Alfaro Solana <felipe_alfaro@linuxmail.org> wrote:
|>What is happening is that some subsystem is holding a reference to the
device (calling dev_hold())
|>but not cleaning up (calling dev_put).  It can be a hard to track
which of the many
|>things routing, etc are not being cleared properly.  Look for routes
that still
|>get stuck (ip route) and neighbor cache entries.  Most of these end up
being
|>protocol bugs.
|
|
| The two attached patches, one for net/ipv4/route.c, the other for net/
| ipv6/route.c fix all my problems when running "cardctl eject" while a
| program mantains an open network socket (ESTABLISHED).
|
| Both patches apply cleanly against 2.6.7-rc3 and 2.6.7-rc3-mm1.
| I'm not completely sure what has changed in 2.6.7-rc3 that is breaking
| cardctl for me, as it Just Worked(TM) fine in 2.6.7-rc2.

do you know, by any chance, if this error is dependent to eth0 only or
could help for my error message too:

unregister_netdevice: waiting for ppp0 to become free. Usage count = 1

happened just a few hours ago (2.6.7-rc3), i had to reboot the box
anyway, but pppd was not able to die (even with kill -9)

Christian.
- --
BOFH excuse #258:

That's easy to fix, but I can't be bothered.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFAx5PN+A7rjkF8z0wRAuR+AJ41024qDMPVWYlVeofUZ6N50E3oRwCfeqhs
/GxxIqmDbClJXw/i2WNhJt4=
=lHgP
-----END PGP SIGNATURE-----
