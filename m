From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: macb: initialize checksum when using checksum
 offloading
Date: Tue, 06 Sep 2016 13:43:59 -0700 (PDT)
Message-ID: <20160906.134359.334009778514208272.davem@davemloft.net>
References: <1472479045-8814-2-git-send-email-helmut.buchsbaum@gmail.com>
        <1473005387-24917-1-git-send-email-helmut.buchsbaum@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, tom@herbertland.com,
        michal.simek@xilinx.com, netdev@vger.kernel.org,
        cyrille.pitchen@atmel.com
To: helmut.buchsbaum@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53718 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934248AbcIFUoB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 16:44:01 -0400
In-Reply-To: <1473005387-24917-1-git-send-email-helmut.buchsbaum@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Date: Sun,  4 Sep 2016 18:09:47 +0200

> I'm still struggling to get this fix right..
> 
> Changes since v2:
>  - do not blindly modify SKB contents according to Dave's legitimate
>    objection
> 
> Changes since v1:
>  - dropped disabling HW checksum offload for Zynq
>  - initialize checksum similar to net/ethernet/freescale/fec_main.c
> 
> -- >8 --
> MACB/GEM needs the checksum field initialized to 0 to get correct
> results on transmit in all cases, e.g. on Zynq, UDP packets with
> payload <= 2 otherwise contain a wrong checksums.
> 
> Signed-off-by: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>

Applied.
