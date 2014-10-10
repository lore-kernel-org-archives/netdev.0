From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/1] Checkpatch: coding style errors in Nvidia ethernet
 driver
Date: Fri, 10 Oct 2014 08:03:07 -0700
Message-ID: <1412953387.8770.23.camel@joe-AO725>
References: <1412928102-1696-1-git-send-email-akshaysarode21@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: John Stultz <john.stultz@linaro.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Akshay Sarode <akshaysarode21@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0138.hostedemail.com ([216.40.44.138]:38389 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753917AbaJJPDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 11:03:11 -0400
In-Reply-To: <1412928102-1696-1-git-send-email-akshaysarode21@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-10 at 13:31 +0530, Akshay Sarode wrote:
> ERROR: "foo* bar" should be "foo *bar"
> ERROR: do not initialise statics to 0 or NULL
> CHECK: spinlock_t definition without comment
> Signed-off-by: Akshay Sarode <akshaysarode21@gmail.com>
[]
> diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
[]
> @@ -911,12 +913,18 @@ enum {
[]
>  /*
>   * Debug output control for tx_timeout
>   */
> -static bool debug_tx_timeout = false;
> +enum {
> +	NV_DEBUG_TX_TIMEOUT_DISABLED,
> +	NV_DEBUG_TX_TIMEOUT_ENABLED
> +};
> +
> +static bool debug_tx_timeout = NV_DEBUG_TX_TIMEOUT_DISABLED;

Adding this enum is not useful.
