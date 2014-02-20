From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 05/14 v2] i40evf: fix up strings in init task
Date: Wed, 19 Feb 2014 20:09:10 -0800
Message-ID: <1392869350.24844.22.camel@joe-AO722>
References: <1392868178-7011-1-git-send-email-aaron.f.brown@intel.com>
	 <1392868178-7011-2-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Aaron Brown <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0229.hostedemail.com ([216.40.44.229]:35031 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752748AbaBTEJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 23:09:13 -0500
In-Reply-To: <1392868178-7011-2-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-02-19 at 19:49 -0800, Aaron Brown wrote:
> Make sure errors are reported at the correct log level, quit printing
> the function name every time, and make the messages more consistent in
> format.
[]
> diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
[]
> @@ -2041,9 +2038,8 @@ static void i40evf_init_task(struct work_struct *work)
>  
>  	/* The HW MAC address was set and/or determined in sw_init */
>  	if (!is_valid_ether_addr(adapter->hw.mac.addr)) {
> -		dev_info(&pdev->dev,
> -			"Invalid MAC address %pMAC, using random\n",
> -			adapter->hw.mac.addr);
> +		dev_info(&pdev->dev, "Invalid MAC address %pMAC, using random\n",
> +			 adapter->hw.mac.addr);

The "AC" after %pM is superfluous.
