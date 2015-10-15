From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 03/17] i40evf: Add support for netpoll
Date: Fri, 16 Oct 2015 01:10:31 +0300
Message-ID: <56202457.90403@cogentembedded.com>
References: <1444945404-30654-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1444945404-30654-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:35943 "EHLO
	mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbbJOWKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 18:10:35 -0400
Received: by lfeh64 with SMTP id h64so49560901lfe.3
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 15:10:33 -0700 (PDT)
In-Reply-To: <1444945404-30654-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/16/2015 12:43 AM, Jeff Kirsher wrote:

> From: Alexander Duyck <aduyck@mirantis.com>
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40evf/i40evf_main.c | 26 +++++++++++++++++++++++++
>   1 file changed, 26 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> index 429a46c..5e13363 100644
> --- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> +++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> @@ -444,6 +444,29 @@ out:
>   	return err;
>   }
>
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +/**
> + * i40evf_netpoll - A Polling 'interrupt'handler

    Space obviously missing.

[...]

MBR, Sergei
