From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Revert "at803x: fix suspend/resume for SGMII link"
Date: Thu, 27 Oct 2016 16:05:55 -0400 (EDT)
Message-ID: <20161027.160555.484554256733814943.davem@davemloft.net>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
        <1477305654-11328-2-git-send-email-zefir.kurtisi@neratec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, timur@codeaurora.org, andrew@lunn.ch,
        f.fainelli@gmail.com
To: zefir.kurtisi@neratec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33404 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754447AbcJ0UF5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 16:05:57 -0400
In-Reply-To: <1477305654-11328-2-git-send-email-zefir.kurtisi@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Date: Mon, 24 Oct 2016 12:40:53 +0200

> This reverts commit 98267311fe3b334ae7c107fa0e2413adcf3ba735.
> 
> Suspending the SGMII alongside the copper side
> made the at803x inaccessable while powered down,
> e.g. it can't be re-probed after suspend.
> 
> Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>

Applied.
