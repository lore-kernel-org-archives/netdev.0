From: Arseny Solokha <asolokha@kb.kras.ru>
Subject: [PATCH 0/2] DMA API usage fixes in gianfar
Date: Fri,  5 Dec 2014 17:37:52 +0700
Message-ID: <1417775874-17775-1-git-send-email-asolokha@kb.kras.ru>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arseny Solokha <asolokha@kb.kras.ru>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

This patch set fixes DMA API usage issues in gianfar ethernet driver
reported by the kernel w/ DMA API debug enabled.

There were even reports that the kernel sometimes oopsed in the past
because of kernel paging request handling failures, though it was likely
observed on some ancient versions. And while I personally doesn't have
any strong evidence of this, there's no reason to let these possible
failures live any longer.

Arseny Solokha (2):
  gianfar: handle map error in gfar_new_rxbdp()
  gianfar: handle map error in gfar_start_xmit()

 drivers/net/ethernet/freescale/gianfar.c | 49 ++++++++++++++++++++++++++------
 1 file changed, 41 insertions(+), 8 deletions(-)

-- 
Regards,
Arseny Solokha.
