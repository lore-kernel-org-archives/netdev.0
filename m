From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/5] GTP: Fine-tuning for some function implementations
Date: Thu, 26 Jan 2017 11:15:20 +0100
Message-ID: <698070a4-e08e-78e5-0214-df69783cce22@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Harald Welte <laforge@gnumonks.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Pablo Neira <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 26 Jan 2017 11:10:01 +0100

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (5):
  Use kmalloc_array() in gtp_hashtable_new()
  Improve another size determination in ipv4_pdp_add()
  Adjust 12 checks for null pointers
  Rename jump labels in gtp_encap_enable()
  Rename jump labels in gtp_hashtable_new()

 drivers/net/gtp.c | 46 ++++++++++++++++++++++++----------------------
 1 file changed, 24 insertions(+), 22 deletions(-)

-- 
2.11.0
