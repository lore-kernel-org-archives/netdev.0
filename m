From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH v2 02/12] net: ethernet: aquantia: Common functions and
 definitions
Date: Sat, 7 Jan 2017 01:29:50 +0100
Message-ID: <9d914d2b-359f-aa9a-6d8a-e1bf8e54f290@gmx.de>
References: <cover.1483689029.git.vomlehn@texas.net>
 <41e24066f2a87cad644a902658846e109a6b406f.1483689029.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>
To: Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:64055 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934131AbdAGAaC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 19:30:02 -0500
In-Reply-To: <41e24066f2a87cad644a902658846e109a6b406f.1483689029.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 06.01.2017 09:06, Alexander Loktionov wrote:
> +
> +#define TXT(_T_) #_T_
> +#define TXTTXT(_T_) TXT(_T_)

do you really need these (IMHO ugly) macros? AFAICS you only use them to 
build the driver
version string.
> +
> +#define AQ_CFG_DRV_AUTHOR      "aQuantia"
> +#define AQ_CFG_DRV_DESC        "aQuantia Corporation(R) Network Driver"
> +#define AQ_CFG_DRV_NAME        "aquantia"
> +#define AQ_CFG_DRV_VERSION	TXTTXT(NIC_MAJOR_DRIVER_VERSION)"."\
> +				TXTTXT(NIC_MINOR_DRIVER_VERSION)"."\
> +				TXTTXT(NIC_BUILD_DRIVER_VERSION)"."\
> +				TXTTXT(NIC_REVISION_DRIVER_VERSION)

Regards,
Lino
