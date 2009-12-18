From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH] broadcom: bcm54xx_shadow_read() errors ignored in
 bcm54xx_adjust_rxrefclk()
Date: Thu, 17 Dec 2009 17:41:39 -0800
Message-ID: <20091218014138.GA22080@xw6200.broadcom.net>
References: <4B28DA62.40909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Roel Kluin" <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1798 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751003AbZLRBls (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2009 20:41:48 -0500
In-Reply-To: <4B28DA62.40909@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2009 at 05:02:26AM -0800, Roel Kluin wrote:
> If not signed read errors are ignored.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Acked-by: Matt Carlson <mcarlson@broadcom.com>

> ---
> Found using coccinelle: http://coccinelle.lip6.fr/
> 
> diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
> index f63c96a..c13cf64 100644
> --- a/drivers/net/phy/broadcom.c
> +++ b/drivers/net/phy/broadcom.c
> @@ -326,7 +326,8 @@ error:
>  
>  static void bcm54xx_adjust_rxrefclk(struct phy_device *phydev)
>  {
> -	u32 val, orig;
> +	u32 orig;
> +	int val;
>  	bool clk125en = true;
>  
>  	/* Abort if we are using an untested phy. */
> 

