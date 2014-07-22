From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 1/2] ethernet: realtek: use module_pci_driver
Date: Tue, 22 Jul 2014 18:38:51 +0400
Message-ID: <53CE777B.3080301@cogentembedded.com>
References: <1406013622-27869-1-git-send-email-varkabhadram@gmail.com> <1406013622-27869-2-git-send-email-varkabhadram@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: varkabhadram@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:64932 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755345AbaGVOix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 10:38:53 -0400
Received: by mail-la0-f48.google.com with SMTP id gl10so6022393lab.7
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 07:38:52 -0700 (PDT)
In-Reply-To: <1406013622-27869-2-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2014 11:20 AM, varkabhadram@gmail.com wrote:

> From: Varka Bhadram <varkab@cdac.in>

> This patch converts to use the macro module_pci_driver, which makes
> the code smaller and simpler.

> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> ---
>   drivers/net/ethernet/realtek/8139cp.c |   22 ++--------------------
>   1 file changed, 2 insertions(+), 20 deletions(-)

> diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
> index 2bc728e..9fb68b9 100644
> --- a/drivers/net/ethernet/realtek/8139cp.c
> +++ b/drivers/net/ethernet/realtek/8139cp.c
> @@ -1887,11 +1887,7 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
>   	resource_size_t pciaddr;
>   	unsigned int addr_len, i, pci_using_dac;
>
> -#ifndef MODULE
> -	static int version_printed;
> -	if (version_printed++ == 0)
> -		pr_info("%s", version);
> -#endif
> +	pr_info("%s", version);

    Use pr_info_once().

WBR, Sergei
