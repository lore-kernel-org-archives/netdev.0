From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 4/5] cxgb4 : Makefile & Kconfig changes for DCBx
 support
Date: Fri, 20 Jun 2014 20:51:54 +0400
Message-ID: <53A466AA.9080305@cogentembedded.com>
References: <1403216531-7874-1-git-send-email-anish@chelsio.com> <1403216531-7874-5-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, leedom@chelsio.com, hariprasad@chelsio.com
To: Anish Bhatt <anish@chelsio.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:43207 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753633AbaFTQvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 12:51:46 -0400
Received: by mail-lb0-f177.google.com with SMTP id u10so2532483lbd.36
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 09:51:44 -0700 (PDT)
In-Reply-To: <1403216531-7874-5-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/20/2014 02:22 AM, Anish Bhatt wrote:

> Signed-off-by: Anish Bhatt <anish@chelsio.com>
> ---
>   drivers/net/ethernet/chelsio/Kconfig        | 11 +++++++++++
>   drivers/net/ethernet/chelsio/cxgb4/Makefile |  1 +
>   2 files changed, 12 insertions(+)

> diff --git a/drivers/net/ethernet/chelsio/Kconfig b/drivers/net/ethernet/chelsio/Kconfig
> index 570222c..c3ce9df 100644
> --- a/drivers/net/ethernet/chelsio/Kconfig
> +++ b/drivers/net/ethernet/chelsio/Kconfig
> @@ -86,6 +86,17 @@ config CHELSIO_T4
>   	  To compile this driver as a module choose M here; the module
>   	  will be called cxgb4.
>
> +config CHELSIO_T4_DCB
> +	bool "Data Center Bridging (DCB) Support for Chelsio T4/T5 cards"
> +	default n

    'n' is the default default. :-)

> +	depends on CHELSIO_T4 && DCB
> +	---help---
> +	  Enable DCB support through rtNetlink interface.
> +	  Say Y here if you want to enable Data Center Bridging (DCB) support
> +	  in the driver.
> +
> +	  If unsure, say N.
> +

WBR, Sergei
