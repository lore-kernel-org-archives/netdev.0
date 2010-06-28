From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH -next] bnx2x: fail when try to setup unsupported
 features
Date: Mon, 28 Jun 2010 14:07:02 +0300
Message-ID: <1277723222.28932.18.camel@lb-tlvb-eilong.il.broadcom.com>
References: <20100628112811.29881285@dhcp-lab-109.englab.brq.redhat.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Amerigo Wang" <amwang@redhat.com>
To: "Stanislaw Gruszka" <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1980 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751031Ab0F1LHT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 07:07:19 -0400
In-Reply-To: <20100628112811.29881285@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-06-28 at 02:28 -0700, Stanislaw Gruszka wrote:
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Thanks Stanislaw!

> ---
>  drivers/net/bnx2x_main.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
> index 57ff5b3..0809f6c 100644
> --- a/drivers/net/bnx2x_main.c
> +++ b/drivers/net/bnx2x_main.c
> @@ -10982,6 +10982,9 @@ static int bnx2x_set_flags(struct net_device *dev, u32 data)
>  	int changed = 0;
>  	int rc = 0;
>  
> +	if (data & ~(ETH_FLAG_LRO | ETH_FLAG_RXHASH))
> +		return -EOPNOTSUPP;
> +
>  	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
>  		printk(KERN_ERR "Handling parity error recovery. Try again later\n");
>  		return -EAGAIN;



