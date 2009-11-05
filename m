From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH 2/6] Staging: Octeon: Use symbolic values for irq numbers.
Date: Thu, 05 Nov 2009 16:25:58 +0100
Message-ID: <20091105152702.125802957@linux-mips.org>
References: <20091105152555.227009519@linux-mips.org>
Cc: David Daney <ddaney@caviumnetworks.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline; filename=0003.patch
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney@caviumnetworks.com>

In addition to being magic numbers, the irq number passed to free_irq
is incorrect.  We need to use the correct symbolic value instead.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: devel@driverdev.osuosl.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org
Cc: netdev@vger.kernel.org
Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 drivers/staging/octeon/ethernet-spi.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: upstream-linus/drivers/staging/octeon/ethernet-spi.c
===================================================================
--- upstream-linus.orig/drivers/staging/octeon/ethernet-spi.c
+++ upstream-linus/drivers/staging/octeon/ethernet-spi.c
@@ -317,6 +317,6 @@ void cvm_oct_spi_uninit(struct net_devic
 			cvmx_write_csr(CVMX_SPXX_INT_MSK(interface), 0);
 			cvmx_write_csr(CVMX_STXX_INT_MSK(interface), 0);
 		}
-		free_irq(8 + 46, &number_spi_ports);
+		free_irq(OCTEON_IRQ_RML, &number_spi_ports);
 	}
 }
