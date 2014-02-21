From: Soren Brinkmann <soren.brinkmann@xilinx.com>
Subject: [PATCH RFC 0/2] net: macb: Fixing DMA usage
Date: Fri, 21 Feb 2014 11:30:23 -0800
Message-ID: <1393011025-18537-1-git-send-email-soren.brinkmann@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vinod Koul <vinod.koul@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Simek <michal.simek@xilinx.com>,
	Soren Brinkmann <soren.brinkmann@xilinx.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

when I enabled CONFIG_DMA_API_DEBUG recently, I started seeing warnings
caused by the macb's DMA usage.
I read trough Documentation/DMA-API_HOWTO.txt and tried solving these t=
o
the best of my knowledge of the networking and DMA systems. But that
knowledge is not very deep. So, there might be fundamental flaws with
these patches, hence as RFC only.

	Thanks,
	S=C3=B6ren

Soren Brinkmann (2):
  net: macb: Check DMA mappings for error
  net: macb: DMA-unmap full rx-buffer

 drivers/net/ethernet/cadence/macb.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

--=20
1.9.0.1.g4196000
