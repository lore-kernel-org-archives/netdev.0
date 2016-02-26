From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 0/3] bridge: mcast: add support for temp
	router port
Date: Fri, 26 Feb 2016 19:59:23 +0100
Message-ID: <1456513166-20159-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi,
This set adds support for temporary router port which doesn't depend on
the incoming queries. It can be refreshed by setting multicast_router to
the same value (3). The first two patches are minor changes that prepare
the code for the third which adds this new type of router port.
In order to be able to dump its information the mdb router port format
is changed and extended similar to how mdb entries format was done
recently.
The related iproute2 changes will be posted if this is accepted.

Thanks,
 Nik

Nikolay Aleksandrov (3):
  bridge: mcast: use names for the different multicast_router types
  bridge: mcast: do nothing if port's multicast_router is set to the
    same val
  bridge: mcast: add support for temporary port router

 include/uapi/linux/if_bridge.h | 22 +++++++++++-
 net/bridge/br_mdb.c            | 16 +++++++--
 net/bridge/br_multicast.c      | 80 +++++++++++++++++++++++++++---------------
 3 files changed, 86 insertions(+), 32 deletions(-)

-- 
2.4.3
