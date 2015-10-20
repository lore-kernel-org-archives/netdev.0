From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH net-next v3] bnxt_en: New Broadcom ethernet driver.
Date: Tue, 20 Oct 2015 16:00:47 -0400
Message-ID: <20151020200047.GD23569@tuxdriver.com>
References: <1445055704-6103-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, prashant@broadcom.com, eddie.wai@broadcom.com,
	huangjw@broadcom.com, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44761 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609AbbJTUPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 16:15:16 -0400
Content-Disposition: inline
In-Reply-To: <1445055704-6103-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 17, 2015 at 12:21:44AM -0400, Michael Chan wrote:
> Broadcom ethernet driver for the new family of NetXtreme-C/E
> ethernet devices.
> 
> v3:
>   - Fixed 2 more sparse warnings.
>   - Removed some unused structures in .h files.
> 
> v2:
>   - Fixed all kbuild test robot reported warnings.
>   - Fixed many of the checkpatch.pl errors and warnings.
>   - Fixed the Kconfig description.
> 
> Acked-by: Eddie Wai <eddie.wai@broadcom.com>
> Acked-by: Jeffrey Huang <huangjw@broadcom.com>
> Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

...

Looks pretty good so far...

> +	if (req.hwrm_intf_maj != resp->hwrm_intf_maj ||
> +	    req.hwrm_intf_min != resp->hwrm_intf_min ||
> +	    req.hwrm_intf_upd != resp->hwrm_intf_upd) {
> +		netdev_warn(bp->dev, "HWRM interface %d.%d.%d does not match driver interface %d.%d.%d.  Please update driver or firmware with matching interface versions.\n",
> +			    resp->hwrm_intf_maj, resp->hwrm_intf_min,
> +			    resp->hwrm_intf_upd, req.hwrm_intf_maj,
> +			    req.hwrm_intf_min, req.hwrm_intf_upd);
> +	}

Any chance we could break that string and/or make it a bit shorter?
Thats a long one! (130+ characters)

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
