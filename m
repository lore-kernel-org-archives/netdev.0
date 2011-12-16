From: David Decotigny <decot@googlers.com>
Subject: [PATCH net-next v1 0/6] tg3: adaptive interrupt coalescing, non-napi mode
Date: Fri, 16 Dec 2011 10:19:43 -0800
Message-ID: <cover.1324059527.git.decot@googlers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Javier Martinez Canillas <martinez.javier@gmail.com>,
	Robin Getz <rgetz@blackfin.uclinux.org>,
	Matt Mackall <mpm@selenic.com>,
	David Decotigny <decot@googlers.com>
To: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series implements adaptive interrupt coalescing for tg3 NIC,
improving performance substancially. It also implements non-NAPI mode
for specific system loads.

############################################
# Patch Set Summary:

David Decotigny (2):
  tg3: fix possible infinite loop
  tg3: move functions related to reset_task together

Maciej =C5=BBenczykowski (1):
  tg3: Remove IRQF_SAMPLE_RANDOM flag from internal tests

Tom Herbert (1):
  tg3: implementation of a non-NAPI mode

Ying Cai (2):
  tg3: Implement adaptive interrupt coalescing
  tg3: use netif_tx_start_queue instead of wake_queue when no
    reschedule needed

 drivers/net/ethernet/broadcom/Kconfig |    8 +
 drivers/net/ethernet/broadcom/tg3.c   |  379 +++++++++++++++++++++++++=
+++++---
 drivers/net/ethernet/broadcom/tg3.h   |   42 ++++
 3 files changed, 397 insertions(+), 32 deletions(-)

--=20
1.7.3.1
