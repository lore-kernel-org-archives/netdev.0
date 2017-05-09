From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/4] hamradio: Fine-tuning for nine function implementations
Date: Tue, 9 May 2017 16:21:14 +0200
Message-ID: <4c5c939a-bd55-7b88-8e41-49f5544b7658@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        Jean-Paul Roubelat <jpr@f6fbb.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 9 May 2017 16:11:23 +0200

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (4):
  Combine two seq_printf() calls into one in yam_seq_show()
  Adjust four function calls together with a variable assignment
  Use seq_puts() in bpq_seq_show()
  Adjust four function calls together with a variable assignment

 drivers/net/hamradio/bpqether.c | 14 +++++++++-----
 drivers/net/hamradio/yam.c      | 15 +++++++++------
 2 files changed, 18 insertions(+), 11 deletions(-)

-- 
2.12.2
