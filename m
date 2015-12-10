From: Sunil Goutham <sunil.kovvuri@gmail.com>
Subject: [PATCH v2 0/2] net: thunderx: Support for pass-2 hw features
Date: Thu, 10 Dec 2015 13:25:18 +0530
Message-ID: <1449734120-8912-1-git-send-email-sunil.kovvuri@gmail.com>
References: <y>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>, Sunil.Goutham@caviumnetworks.com,
 p.fedin@samsung.com, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <y>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This patch set adds support for new features added in pass-2 revision
of hardware like TSO and count based interrupt coalescing.

Changes from v1:
- Addressed comments received regarding boolean bit field changes 
  by excluding them from this patch. Will submit a seperate
  patch along with cleanup of unsed field.
- Got rid of new macro 'VNIC_NAPI_WEIGHT' introduced in 
  count threshold interrupt patch.

Sunil Goutham (2):
  net: thunderx: HW TSO support for pass-2 hardware
  net: thunderx: Enable CQE count threshold interrupt

 drivers/net/ethernet/cavium/thunder/nic.h          |    6 ++++
 drivers/net/ethernet/cavium/thunder/nic_main.c     |   11 ++-----
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |   15 ++++++++-
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |   22 ++++++++++----
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |    2 +-
 drivers/net/ethernet/cavium/thunder/q_struct.h     |   30 ++++++++++---------
 6 files changed, 55 insertions(+), 31 deletions(-)
