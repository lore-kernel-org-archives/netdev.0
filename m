From: Srishti Sharma <srishtishar@gmail.com>
Subject: [PATCH 0/2] Assign outside if
Date: Sat, 16 Sep 2017 02:35:24 +0530
Message-ID: <cover.1505508423.git.srishtishar@gmail.com>
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
        devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com,
        Srishti Sharma <srishtishar@gmail.com>
To: samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series intends to remove the assignment statements 
inside the if statement, and eliminates the cases of parentheses
around the right hand side of assignment generated as a result of 
the same.

Srishti Sharma (2):
  Staging: irda: Don't use assignment inside if statement
  Staging: irda: Remove parentheses on the right of assignment

 drivers/staging/irda/drivers/irda-usb.c | 4 ++--
 drivers/staging/irda/drivers/mcs7780.c  | 9 ++++++---
 drivers/staging/irda/net/irqueue.c      | 3 ++-
 3 files changed, 10 insertions(+), 6 deletions(-)

-- 
2.7.4
