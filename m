From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/6] netvsc: small cleanups
Date: Thu,  8 Jun 2017 16:21:17 -0700
Message-ID: <20170608232123.28366-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

These are all small optimizations found during development of later features.

Stephen Hemminger (6):
  netvsc: optimize calculation of number of slots
  netvsc: use hv_get_bytes_to_read
  netvsc: use typed pointer for internal state
  netvsc: mark error cases as unlikely
  netvsc: pass net_device to netvsc_init_buf and netvsc_connect_vsp
  netvsc: fold in get_outbound_net_device

 drivers/net/hyperv/hyperv_net.h |  3 +--
 drivers/net/hyperv/netvsc.c     | 49 ++++++++++++-------------------------
 drivers/net/hyperv/netvsc_drv.c | 53 ++++++++++-------------------------------
 3 files changed, 29 insertions(+), 76 deletions(-)

-- 
2.11.0
