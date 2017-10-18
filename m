From: Scott Branden <scott.branden@broadcom.com>
Subject: Re: [PATCH 1/1] net: ethtool: add support for reset of AP inside NIC
 interface.
Date: Wed, 18 Oct 2017 14:59:57 -0700
Message-ID: <5a0da7ea-0ac0-5cac-ab15-a5de9a58922f@broadcom.com>
References: <1508342496-5047-1-git-send-email-scott.branden@broadcom.com>
 <1508342496-5047-2-git-send-email-scott.branden@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
        linux-kernel@vger.kernel.org, Steve Lin <steven.lin1@broadcom.com>,
        netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        "Allan W. Nielsen" <allan.nielsen@microsemi.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:49550 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751544AbdJRWAC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 18:00:02 -0400
Received: by mail-qk0-f194.google.com with SMTP id q83so8137509qke.6
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 15:00:01 -0700 (PDT)
In-Reply-To: <1508342496-5047-2-git-send-email-scott.branden@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+netdev@vger.kernel.org


On 17-10-18 09:01 AM, Scott Branden wrote:
> Add ETH_RESET_AP to reset the application processor inside the NIC
> interface.
>
> Signed-off-by: Scott Branden <scott.branden@broadcom.com>
> ---
>   include/uapi/linux/ethtool.h | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index 5bd1b1d..f927ab7 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -1685,6 +1685,7 @@ enum ethtool_reset_flags {
>   	ETH_RESET_PHY		= 1 << 6,	/* Transceiver/PHY */
>   	ETH_RESET_RAM		= 1 << 7,	/* RAM shared between
>   						 * multiple components */
> +	ETH_RESET_AP		= 1 << 8,	/* Application processor */
>   
>   	ETH_RESET_DEDICATED	= 0x0000ffff,	/* All components dedicated to
>   						 * this interface */
