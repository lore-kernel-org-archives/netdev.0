From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 00/13] net: simplify seq_file code, revised
Date: Tue, 09 Feb 2010 17:18:01 +0800
Message-ID: <4B712849.9040400@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset introduces seq_hlist_foo() helpers, and convert
net/* to seq_hlist_foo() and seq_list_foo().

Changelog:

- Add kerneldoc in patch 1/13
- Fix compile warning in patch 11/13
- Fix a bug in patch 12/13

---
 fs/seq_file.c                 |   60 ++++++++++++++++++++-
 include/linux/seq_file.h      |   11 ++++
 include/net/sock.h            |    5 ++
 net/appletalk/atalk_proc.c    |   30 +----------
 net/atm/proc.c                |    2 +-
 net/atm/resources.c           |   28 +++--------
 net/ax25/af_ax25.c            |   18 +-----
 net/ax25/ax25_uid.c           |   25 ++--------
 net/ipx/ipx_proc.c            |   90 ++++----------------------------
 net/irda/irlan/irlan_common.c |   28 ++---------
 net/key/af_key.c              |   20 +------
 net/netrom/af_netrom.c        |   21 +-------
 net/netrom/nr_route.c         |   53 +++----------------
 net/packet/af_packet.c        |   20 +------
 net/rose/af_rose.c            |   22 +-------
 net/x25/x25_proc.c            |  114 ++++-------------------------------------
 16 files changed, 139 insertions(+), 408 deletions(-)
