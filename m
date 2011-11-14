From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [PATCH net-next] bnx2x: add endline at end of message
Date: Mon, 14 Nov 2011 10:44:25 +0200
Message-ID: <1321260265.19299.1.camel@lb-tlvb-dmitry>
References: <1321260039-19254-1-git-send-email-dmitry@broadcom.com>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Joe Perches" <joe@perches.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3559 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752138Ab1KNIoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Nov 2011 03:44:37 -0500
In-Reply-To: <1321260039-19254-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

git send-email ignored <Reported-by> tag, adding Joe
On Mon, 2011-11-14 at 00:40 -0800, Dmitry Kravkov wrote:
> Reported-by: Joe Perches <joe@perches.com>
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index 33ff60d..c09e59a 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -8520,7 +8520,7 @@ sp_rtnl_not_reset:
>  	 * damage
>  	 */
>  	if (test_and_clear_bit(BNX2X_SP_RTNL_FAN_FAILURE, &bp->sp_rtnl_state)) {
> -		DP(BNX2X_MSG_SP, "fan failure detected. Unloading driver");
> +		DP(BNX2X_MSG_SP, "fan failure detected. Unloading driver\n");
>  		netif_device_detach(bp->dev);
>  		bnx2x_close(bp->dev);
>  	}
