From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/2] hso: neatening
Date: Fri,  2 Sep 2016 15:58:00 -0700
Message-ID: <cover.1472856901.git.joe@perches.com>
Cc: Jan Dumon <j.dumon@option.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: linux-usb@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This seems to be the only code in the kernel that uses
macro defines with a trailing underscore.  Fix that.

Joe Perches (2):
  hso: Use a more common logging style
  hso: Convert printk to pr_<level>

 drivers/net/usb/hso.c | 118 +++++++++++++++++++++++---------------------------
 1 file changed, 55 insertions(+), 63 deletions(-)

-- 
2.10.0.rc2.1.g053435c
