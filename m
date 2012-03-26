From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH 0/1] net/hyperv: Add flow control based on hi/low watermark
Date: Mon, 26 Mar 2012 15:18:23 -0700
Message-ID: <1332800304-5060-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, haiyangz@microsoft.com, olaf@aepfle.de,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

This patch is targeting 'net-next' tree.

Thanks to Stephen Hemminger <shemminger@vyatta.com> for his suggestions.


Haiyang Zhang (1):
  net/hyperv: Add flow control based on hi/low watermark

 drivers/hv/ring_buffer.c        |   15 +++++++++++++++
 drivers/net/hyperv/hyperv_net.h |    3 +++
 drivers/net/hyperv/netvsc.c     |   23 +++++++++++++++++++----
 drivers/net/hyperv/netvsc_drv.c |   16 +++++++++++++++-
 include/linux/hyperv.h          |    3 +++
 5 files changed, 55 insertions(+), 5 deletions(-)

-- 
1.7.4.1
