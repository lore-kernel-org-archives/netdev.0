From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 00/25] Ethernet-Marvell: Fine-tuning for several function
 implementations
Date: Mon, 17 Apr 2017 17:03:33 +0200
Message-ID: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jarod Wilson <jarod@redhat.com>,
        Jisheng Zhang <jszhang@marvell.com>,
        Mirko Lindner <mlindner@marvell.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Russell King <rmk+kernel@armlinux.org.uk>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 17 Apr 2017 16:44:32 +0200

Several update suggestions were taken into account
from static source code analysis.

Markus Elfring (25):
  Use devm_kmalloc_array() in mvneta_init()
  Improve two size determinations in mvneta_init()
  Use kmalloc_array() in mvneta_txq_init()
  Adjust six checks for null pointers
  Use kmalloc_array() in mvpp2_txq_init()
  Improve two size determinations in mvpp2_probe()
  Improve another size determination in mvpp2_init()
  Improve another size determination in mvpp2_port_probe()
  Improve another size determination in mvpp2_bm_init()
  Improve another size determination in mvpp2_prs_default_init()
  Improve 27 size determinations
  Improve a size determination in two functions
  Fix a jump label position in mvpp2_rx()
  Rename a jump label in two functions
  Adjust three error messages
  Rename a jump label in mvpp2_tx_frag_process()
  Rename a jump label in mvpp2_txq_init()
  Rename a jump label in mvpp2_prs_double_vlan_add()
  Rename a jump label in mvpp2_prs_vlan_add()
  Adjust a null pointer check in mvpp2_egress_enable()
  Use kcalloc() in two functions
  Adjust four checks for null pointers
  Use seq_puts() in skge_debug_show()
  Adjust a null pointer check in skge_down()
  Use seq_puts() in sky2_debug_show()

 drivers/net/ethernet/marvell/mvneta.c     |  29 +++----
 drivers/net/ethernet/marvell/mvpp2.c      | 127 ++++++++++++++----------------
 drivers/net/ethernet/marvell/pxa168_eth.c |  14 ++--
 drivers/net/ethernet/marvell/skge.c       |   4 +-
 drivers/net/ethernet/marvell/sky2.c       |   2 +-
 5 files changed, 84 insertions(+), 92 deletions(-)

-- 
2.12.2
