From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH v2 net-next 0/2] ravb: Support 1Gbps on R-Car H3 ES1.1+ and R-Car M3-W
Date: Fri, 27 Jan 2017 19:35:18 +0100
Message-ID: <1485542120-10205-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this series adds support for gigabit communication to the Renesas EthernetAVB
controller when used in conjunction with  R-Car Gen3 H3 ES1.1+ and M3-W SoCs.
Gigabit is already supported with R-Car Gen 2 SoCs.

The patch from Geert was previously posted for inclusion in v4.10 and
acked by Dave for that purpose. It was, however, not accepted by the
ARM SoC maintainers.

The path from Mizuguchi-san is to address timing problems observed with
gigabit transfers. I would like it considered although my own testing on
M3-W did not show any timing problems.

Changes since v1:
* Address various feedback for "APSR" patch as noted in its changelog

Geert Uytterhoeven (1):
  ravb: Support 1Gbps on R-Car H3 ES1.1+ and R-Car M3-W

Kazuya Mizuguchi (1):
  ravb: Add tx and rx clock internal delays mode of APSR

 drivers/net/ethernet/renesas/ravb.h      | 10 ++++++++++
 drivers/net/ethernet/renesas/ravb_main.c | 34 ++++++++++++++++++++++++++++++--
 2 files changed, 42 insertions(+), 2 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
