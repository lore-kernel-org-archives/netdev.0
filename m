From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: unregister_netdevice: waiting for tun6to4 to become free.
Date: Tue, 21 Sep 2004 00:24:53 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920212453.GA15392@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hiya

When trying to do /etc/init.d/network stop (or reboot) my
fc3test-all-updated-so-kernel-is-2.6.9-rc2-bk5ish, the thing hangs with a
"unregister_netdevice: waiting for tun6to4 to become free. Usage count = 1".
The 6to4 tunnel is over the kernel PPPoE tunnel in case that makes a
difference

What it's trying to do is /sbin/ip tunnel del tun6to4, which 
works just fine when run by itself, when looking at /proc/net/dev the
device is no longer there at that point. I think the situation where it 
breaks if the ppp device it's running on top of goes down just before. Just
a guess tho :-)

Any obvious explanations or should I poke further?
