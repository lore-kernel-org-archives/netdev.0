From: Heiko Stuebner <heiko@sntech.de>
Subject: Re: [PATCH net-next 0/4] stmmac: dwmac-rk: convert to standard PM/remove functions
Date: Wed, 09 Nov 2016 20:14:23 +0100
Message-ID: <6241984.qhtTRLrLyd@phil>
References: <20161105130452.24226-1-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, linux-rockchip@lists.infradead.org,
        vpalatin@chromium.org, peppe.cavallaro@st.com,
        netdev@vger.kernel.org
To: Joachim Eastwood <manabian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gloria.sntech.de ([95.129.55.99]:50733 "EHLO gloria.sntech.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750927AbcKITOb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 14:14:31 -0500
In-Reply-To: <20161105130452.24226-1-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Samstag, 5. November 2016, 14:04:48 CET schrieb Joachim Eastwood:
> This patch set aims to remove the init/exit callbacks from the
> dwmac-rk driver and instead use standard PM callbacks. Eventually
> the init/exit callbacks will be deprecated and removed from all
> drivers dwmac-* except for dwmac-generic. Drivers will be refactored
> to use standard PM and remove callbacks.
> 
> This conversion was pretty straight forward, but it would really nice
> if some chromium people could test suspend/resume with this patch set.

while I couldn't test suspens/resume specifically, I at least can confirm that 
regular probing + usage still works :-)

Dave already applied the series, but anyway
Tested-by: Heiko Stuebner <heiko@sntech.de>

Heiko
