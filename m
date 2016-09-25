From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/5] ISDN-CAPI: Fine-tuning for several function
 implementations
Date: Sun, 25 Sep 2016 13:10:04 +0200
Message-ID: <be07f84d-fc84-e47d-207e-aedd8c960151@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 25 Sep 2016 13:03:13 +0200

Some update suggestions were taken into account
from static source code analysis.

Markus Elfring (5):
  Use kmalloc_array() in capidrv_addcontr()
  Delete error messages for a failed memory allocation in four functions
  Adjust 17 function calls together with variable assignments
  Adjust checks for null pointers in four functions
  Delete unnecessary braces

 drivers/isdn/capi/capidrv.c | 111 +++++++++++++++++++++-----------------------
 1 file changed, 54 insertions(+), 57 deletions(-)

-- 
2.10.0
