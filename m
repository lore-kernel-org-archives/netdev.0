From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH 2/2] cpts: fix a run time warn_on.
Date: Sun, 23 Dec 2012 18:07:22 +0400
Message-ID: <50D7101A.6020506@mvista.com>
References: <cover.1356204860.git.richardcochran@gmail.com> <ad26ca328f0eba6a722d0288ac1c37ad55789447.1356204860.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mugunthan V N <mugunthanvnm@ti.com>,
	linux-omap@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org,
	Cyril Chemparathy <cyril@ti.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:42185 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181Ab2LWOHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2012 09:07:22 -0500
Received: by mail-la0-f54.google.com with SMTP id j13so7523848lah.27
        for <netdev@vger.kernel.org>; Sun, 23 Dec 2012 06:07:20 -0800 (PST)
In-Reply-To: <ad26ca328f0eba6a722d0288ac1c37ad55789447.1356204860.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 22-12-2012 23:41, Richard Cochran wrote:

> This patch fixes a warning in clk_enable by calling clk_prepare first.

> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
>   drivers/net/ethernet/ti/cpts.c |    1 +
>   1 files changed, 1 insertions(+), 0 deletions(-)

> diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
> index 5ab8fb4..3e32a31 100644
> --- a/drivers/net/ethernet/ti/cpts.c
> +++ b/drivers/net/ethernet/ti/cpts.c
> @@ -247,6 +247,7 @@ static void cpts_clk_init(struct cpts *cpts)
>   		cpts->refclk = NULL;
>   		return;
>   	}
> +	clk_prepare(cpts->refclk);
>   	clk_enable(cpts->refclk);

    Maybe just call clk_prepare_enable() instead?

WBR, Sergei
