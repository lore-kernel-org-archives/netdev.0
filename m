From: Sergey Matyukevich <sergey.matyukevich.os@quantenna.com>
Subject: Re: [PATCH] wireless: qtnfmac: Convert timers to use timer_setup()
Date: Tue, 17 Oct 2017 11:39:53 +0300
Message-ID: <20171017083951.c56333pxizupnvym@bars>
References: <20171016233622.GA101550@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kalle Valo <kvalo@codeaurora.org>,
        Igor Mitsyanko <imitsyanko@quantenna.com>,
        Avinash Patil <avinashp@quantenna.com>,
        Sergey Matyukevich <smatyukevich@quantenna.com>,
        Kamlesh Rath <krath@quantenna.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0078.outbound.protection.outlook.com ([104.47.36.78]:52000
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754234AbdJQIkG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Oct 2017 04:40:06 -0400
Content-Disposition: inline
In-Reply-To: <20171016233622.GA101550@beast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Igor Mitsyanko <imitsyanko@quantenna.com>
> Cc: Avinash Patil <avinashp@quantenna.com>
> Cc: Sergey Matyukevich <smatyukevich@quantenna.com>
> Cc: Kalle Valo <kvalo@codeaurora.org>
> Cc: Kamlesh Rath <krath@quantenna.com>
> Cc: linux-wireless@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  drivers/net/wireless/quantenna/qtnfmac/cfg80211.c | 7 +++----
>  drivers/net/wireless/quantenna/qtnfmac/core.c     | 2 +-
>  2 files changed, 4 insertions(+), 5 deletions(-)

Reviewed-by: Sergey Matyukevich <sergey.matyukevich.os@quantenna.com>

Thanks!
Sergey
