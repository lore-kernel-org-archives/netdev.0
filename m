From: "David S. Miller" <davem@redhat.com>
Subject: TCP westwood 2.4.x and 2.6.x net BK trees
Date: Sun, 1 Feb 2004 11:49:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040201114936.08f42cad.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


For the BK inclined, I've put up a publicly accessible BK tree of
the 2.4.x TCP Westwood stuff at:

	bk://kernel.bkbits.net/davem/tcpwestwood-2.4

so people can play with it if they want.  Remember you need to enable
the /proc/sys/net/ipv4/tcp_westwood sysctl for the new code to even be
used :-)

I've also put my current 2.6.3-pre1 pending networking tree up at:

	bk://kernel.bkbits.net/davem/net-2.5

It has Stephen's westwood port in it.

Enjoy.

ChangeSet@1.1301.1.1, 2004-01-30 13:05:20-08:00, buffer@antifork.org
  [TCP]: Add Westwood+ support, off by default.

 include/linux/sysctl.h     |    1 
 include/net/sock.h         |   15 ++
 include/net/tcp.h          |  121 ++++++++++++++++++
 net/ipv4/sysctl_net_ipv4.c |    6 
 net/ipv4/tcp_input.c       |  290 ++++++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 429 insertions(+), 4 deletions(-)


ChangeSet@1.1301.1.2, 2004-01-30 14:57:14-08:00, davem@nuts.davemloft.net
  [TCP]: Put tcp_ prefix on global westwood symbols.

 include/net/tcp.h    |   46 +++++++++++++++++++++++-----------------------
 net/ipv4/tcp_input.c |   22 +++++++++++-----------
 2 files changed, 34 insertions(+), 34 deletions(-)


ChangeSet@1.1301.1.3, 2004-01-30 15:19:14-08:00, davem@nuts.davemloft.net
  [TCP]: Coding style fixes to westwood code.

 include/net/tcp.h    |   76 ++++++++++++++++-------------------
 net/ipv4/tcp_input.c |  110 +++++++++++++++++++++++----------------------------
 2 files changed, 87 insertions(+), 99 deletions(-)


ChangeSet@1.1301.1.4, 2004-01-30 15:23:52-08:00, davem@nuts.davemloft.net
  [TCP]: Kill westwood specific lock, unneeded.

 include/net/sock.h   |    1 -
 include/net/tcp.h    |    1 -
 net/ipv4/tcp_input.c |   15 +--------------
 3 files changed, 1 insertion(+), 16 deletions(-)


ChangeSet@1.1301.1.5, 2004-02-01 11:06:29-08:00, davem@nuts.davemloft.net
  [TCP]: Kill bogus reference to CONFIG_TCP_WESTWOOD.

 net/ipv4/tcp_input.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)


ChangeSet@1.1307, 2004-02-01 11:43:53-08:00, davem@kernel.bkbits.net
  Merge davem@nuts.davemloft.net:/disk1/davem/BK/tcp-2.4
  into kernel.bkbits.net:/home/davem/tcpwestwood-2.4

 include/linux/sysctl.h |    1 +
 1 files changed, 1 insertion(+)
