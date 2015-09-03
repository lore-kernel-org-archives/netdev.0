From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: [PATCH 0/3] net: irda: pxaficp_ir: dmaengine conversion
Date: Thu,  3 Sep 2015 08:20:48 +0200
Message-ID: <1441261251-19548-1-git-send-email-robert.jarzmik@free.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Robert Jarzmik <robert.jarzmik@free.fr>
To: Samuel Ortiz <samuel@sortiz.org>, Petr Cvek <petr.cvek@tul.cz>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This serie aims at converting pxaficp_ir to dmaengine. This is almost the last
driver to be converted, and once this is gone, legacy DMA support in pxa
architecture can be gone.

Nothing fancy here, standard readl/writel conversion, then dmaengine support.

The main trouble is that I cannot test it, I only compiled and inserted the
module, which works on lubbock, but I have no way to make a communcation try.

Petr, Dmitry, once the review is advanced enough, ie. in a couple of weeks, do
you have a way to test it on corgi/magician if I give you a git tree to pull
from ?

Cheers

--
Robert

Robert Jarzmik (3):
  net: irda: pxaficp_ir: use sched_clock() for time management
  net: irda: pxaficp_ir: convert to readl and writel
  net: irda: pxaficp_ir: dmaengine conversion

 drivers/net/irda/pxaficp_ir.c | 366 +++++++++++++++++++++++++++---------------
 1 file changed, 233 insertions(+), 133 deletions(-)

-- 
2.1.4
