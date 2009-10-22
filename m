From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH]bnx2x: remove duplication of the BCM_VLAN macro
Date: Thu, 22 Oct 2009 09:42:47 +0200
Message-ID: <1256197367.4101.22.camel@lb-tlvb-eilong>
References: <20091021203851.GA5311@coldcone>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "kirjanov@gmail.com" <kirjanov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3544 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751031AbZJVHpl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2009 03:45:41 -0400
In-Reply-To: <20091021203851.GA5311@coldcone>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-10-21 at 13:38 -0700, Denis Kirjanov 
> File bnx2.c already contains condition of the macro inclusion.
> So we can remove this.

It is true that BCM_VLAN is defined in bnx2.c, however it is not defined
in bnx2x_*.c files. The definition in bnx2x.h is needed for the bnx2x.ko
module.

Please do not remove it.

Thanks,
Eilon

> Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>
> ---
> 
> diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
> index bbf8422..4b99fd2 100644
> --- a/drivers/net/bnx2x.h
> +++ b/drivers/net/bnx2x.h
> @@ -20,10 +20,6 @@
>   * (you will need to reboot afterwards) */
>  /* #define BNX2X_STOP_ON_ERROR */
>  
> -#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
> -#define BCM_VLAN			1
> -#endif
> -
>  
>  #define BNX2X_MULTI_QUEUE
>  



