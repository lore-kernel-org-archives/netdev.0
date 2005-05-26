From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET] neighbour tables access via rtnetlink
Date: Thu, 26 May 2005 20:53:06 +0200
Message-ID: <20050526185306.GW15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

This patchset adds neighbour table configuration and
statistics access via rtnetlink. Patches 1-2 add some
new macros to make netlink message construction simpler
and more readable, patch 3 adds the actual neighbour
table code and patch 4 removes a few unused fields
discovered while writing patch 3 ;->

 include/linux/netlink.h     |   17 ++
 include/linux/rtnetlink.h   |   45 ++++++
 include/net/neighbour.h     |    3 
 include/linux/rtnetlink.h   |  107 ++++++++++++++
 include/net/neighbour.h     |    4 
 net/core/neighbour.c        |  317 +++++++++++++++++++++++++++++++++++++++++++-
 net/core/rtnetlink.c        |   20 +-
 security/selinux/nlmsgtab.c |    2 
 8 files changed, 499 insertions(+), 16 deletions(-)
