From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/4] ATM-ZeitNet: Fine-tuning for three function
 implementations
Date: Sat, 10 Sep 2016 10:57:37 +0200
Message-ID: <0b5381e1-d725-0706-1cc0-188df6c201f2@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        Paolo Bonzini <pbonzini@redhat.com>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        Chas Williams <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 10 Sep 2016 10:54:04 +0200

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (4):
  Use kmalloc_array() in start_tx()
  Improve a size determination in zatm_open()
  Replace one kzalloc() call by kcalloc()
  Fix indentation for one DPRINTK() call in start_rx()

 drivers/atm/zatm.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

-- 
2.10.0
