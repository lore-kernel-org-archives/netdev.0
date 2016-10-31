From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFC] ravb: Support 1Gbps on R-Car H3 ES1.1+ and R-Car
 M3-W
Date: Mon, 31 Oct 2016 13:24:31 -0400 (EDT)
Message-ID: <20161031.132431.648834397805808388.davem@davemloft.net>
References: <1477934018-13968-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, horms+renesas@verge.net.au,
        arnd@arndb.de, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: geert+renesas@glider.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52506 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S944777AbcJaRYe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 13:24:34 -0400
In-Reply-To: <1477934018-13968-1-git-send-email-geert+renesas@glider.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert+renesas@glider.be>
Date: Mon, 31 Oct 2016 18:13:38 +0100

> The limitation to 10/100Mbit speeds on R-Car Gen3 is valid for R-Car H3
> ES1.0 only. Check for the exact SoC model to allow 1Gbps on newer
> revisions of R-Car H3, and on R-Car M3-W.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> ---
> Tested on:
>   - r8a7795/salvator-x with R-Car H3 ES1.0 (limited to 100Mbps),
>   - r8a7795/salvator-x with R-Car H3 ES1.1 (1Gbps),
>   - r8a7796/salvator-x with R-Car M3-W ES1.0 (1Gbps).
> 
> This is marked as an RFC because it depends on:
>   A) the soc_device_match() infrastructure,
>   B) Renesas SoC core ESx.y handling.
> Hence I think the best merge strategy is to let this patch go in through
> Simon's Renesas tree.
> 
> David: If you agree, can you please provide your ack? Thanks!

Sure, no problem:

Acked-by: David S. Miller <davem@davemloft.net>
