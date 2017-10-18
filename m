From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH net-next v2 0/3] net: sh_eth: add R-Car Gen[12] fallback compatibility strings
Date: Wed, 18 Oct 2017 09:21:25 +0200
Message-ID: <20171018072128.11857-1-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Simon Horman <horms+renesas@verge.net.au>
To: David Miller <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add fallback compatibility strings for R-Car Gen 1 and 2.

In the case of Renesas R-Car hardware we know that there are generations of
SoCs, f.e. Gen 1 and 2. But beyond that its not clear what the relationship
between IP blocks might be. For example, I believe that r8a7790 is older
than r8a7791 but that doesn't imply that the latter is a descendant of the
former or vice versa.

We can, however, by examining the documentation and behaviour of the
hardware at run-time observe that the current driver implementation appears
to be compatible with the IP blocks on SoCs within a given generation.

For the above reasons and convenience when enabling new SoCs a
per-generation fallback compatibility string scheme is being adopted for
drivers for Renesas SoCs.

Changes since v1:
* Correct typos in changelogs
* Consistently use tabs for indentation in bindings document
* Enhance readability of description of bindings usage

Simon Horman (3):
  dt-bindings: net: sh_eth: add R-Car Gen[12] fallback compatibility
    strings
  net: sh_eth: rename name structures as rcar_gen[12]_*
  net: sh_eth: implement R-Car Gen[12] fallback compatibility strings

 Documentation/devicetree/bindings/net/sh_eth.txt | 14 +++++++++--
 drivers/net/ethernet/renesas/sh_eth.c            | 32 +++++++++++++-----------
 2 files changed, 29 insertions(+), 17 deletions(-)

-- 
2.11.0
