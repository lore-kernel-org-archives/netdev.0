From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] sh_eth: Do not print an error message for probe
 deferral
Date: Thu, 18 May 2017 11:21:27 -0400 (EDT)
Message-ID: <20170518.112127.1028575897478969091.davem@davemloft.net>
References: <1495112495-25086-1-git-send-email-geert+renesas@glider.be>
        <1495112495-25086-2-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com,
        laurent.pinchart+renesas@ideasonboard.com, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: geert+renesas@glider.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44290 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932767AbdERPV3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 11:21:29 -0400
In-Reply-To: <1495112495-25086-2-git-send-email-geert+renesas@glider.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert+renesas@glider.be>
Date: Thu, 18 May 2017 15:01:35 +0200

> EPROBE_DEFER is not an error, hence printing an error message like
> 
>     sh-eth ee700000.ethernet: failed to initialise MDIO
> 
> may confuse the user.
> 
> To fix this, suppress the error message in case of probe deferral.
> While at it, shorten the message, and add the actual error code.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Applied.
