From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH net-next 0/3] net: sh_eth: add R-Car Gen[12] fallback compatibility strings
Date: Tue, 17 Oct 2017 09:47:44 +0200
Message-ID: <20171017074747.24159-1-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Simon Horman <horms+renesas@verge.net.au>
To: David Miller <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:41342 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752822AbdJQHsD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 03:48:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
per-generation fallback compatibility string scheme being adopted for
drivers for Renesas SoCs.

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
