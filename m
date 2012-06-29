From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next v2 0/4] net: introduce and use IFF_LIFE_ADDR_CHANGE
Date: Fri, 29 Jun 2012 17:10:04 +0200
Message-ID: <1340982608-897-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, shimoda.hiroaki@gmail.com,
	virtualization@lists.linux-foundation.org,
	danny.kukawka@bisect.de, edumazet@google.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

three drivers updated, but this can be used in many others.

v1->v2:
%s/LIFE/LIVE

Jiri Pirko (4):
  net: introduce new priv_flag indicating iface capable of change mac
    when running
  virtio_net: use IFF_LIVE_ADDR_CHANGE priv_flag
  team: use IFF_LIVE_ADDR_CHANGE priv_flag
  dummy: use IFF_LIVE_ADDR_CHANGE priv_flag

 drivers/net/dummy.c      |   15 ++-------------
 drivers/net/team/team.c  |    9 +++++----
 drivers/net/virtio_net.c |   11 +++++------
 include/linux/if.h       |    2 ++
 net/ethernet/eth.c       |    2 +-
 5 files changed, 15 insertions(+), 24 deletions(-)

-- 
1.7.10.4
