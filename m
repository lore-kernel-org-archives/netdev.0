From: Marc.Herbert@ens-lyon.fr
Subject: tg3 set_pauseframe() crash : some reproducibility
Date: Wed, 8 Oct 2003 18:17:05 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310081805560.3607-100000@bologna>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


After crashing some more machines, I got a better understanding of how
to reproduce the tg3.ko kernel segfault reported a few minutes ago.
Sorry for sending two messages for this. I also discovered the command
"reboot -f", which is great :-)

I was wrong when comparing kernel versions: it finally seems to me
that they do not matter. The key factor is apparently

 "ifconfig up|down"

When the interface is down, the tg3 module being freshly loaded, then
any ethtool -A eth1 whatever does segfaults (in kernel).
If the interface is up, then it rolls.

Cheers,

Marc.


PS: still not subscribed to the list. I will read it on the web,
though. Just like the good old Usenet actually, only less convenient.
