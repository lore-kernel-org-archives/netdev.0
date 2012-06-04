From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH 0/1] net/hyperv: Use wait_event on outstanding sends during
 device removal
Date: Mon,  4 Jun 2012 07:35:31 -0700
Message-ID: <1338820532-2345-1-git-send-email-haiyangz@microsoft.com>
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

This patch is targeting net-next tree (when it's available for check in).

Haiyang Zhang (1):
  net/hyperv: Use wait_event on outstanding sends during device removal

 drivers/net/hyperv/hyperv_net.h |    1 +
 drivers/net/hyperv/netvsc.c     |   12 ++++++------
 2 files changed, 7 insertions(+), 6 deletions(-)

-- 
1.7.4.1
