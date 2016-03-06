From: Moritz Fischer <moritz.fischer@ettus.com>
Subject: [RFC] Attempt to add fixed link functionality to macb
Date: Sun,  6 Mar 2016 11:49:37 -0800
Message-ID: <1457293778-13804-1-git-send-email-moritz.fischer@ettus.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Moritz Fischer <moritz.fischer@ettus.com>
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I'm trying to make the dt 'fixed-link' work with the Zynq's GEM on my board.
The endgoal will be to hook it up to an ethernet switch in the PL (FPGA) logic.

Does the attached patch look halfway reasonable? Note the code is pretty hacky,
and it's not 100% working, so I'm more looking for pointers on obvious mistakes than
for a thorough code review.

Thanks in advance,

    Moritz

Moritz Fischer (1):
  net: macb: Attempt to make fixed link working on macb

 drivers/net/ethernet/cadence/macb.c | 63 ++++++++++++++++++++++++-------------
 drivers/net/ethernet/cadence/macb.h |  1 +
 2 files changed, 43 insertions(+), 21 deletions(-)

-- 
2.7.2
