From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 02/11] ixgb: Fix the use of dprintk rather than printk
Date: Fri, 19 May 2006 11:35:34 -0700
Message-ID: <446E0FF6.90307@intel.com>
References: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com> <20060422010034.24255.21136.stgit@jk-desktop.jf.intel.com> <20060422090301.GB26666@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	John Rociak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:18592 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S964776AbWESSgo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 May 2006 14:36:44 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060422090301.GB26666@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> :
>> @@ -486,8 +495,7 @@ ixgb_probe(struct pci_dev *pdev,
>>  	netif_carrier_off(netdev);
>>  	netif_stop_queue(netdev);
>>  
>> -	printk(KERN_INFO "%s: Intel(R) PRO/10GbE Network Connection\n",
>> -		   netdev->name);
>> +	DPRINTK(PROBE, INFO, "Intel(R) PRO/10GbE Network Connection\n");
> 
> It could probably be factored out with ixgb_driver_string.

the driver name is different from the interface/device that it drives - Hence 
the different name. The 'Connection' name as above is the branding name as 
well, and that's why we print it here as such. e1000 does the same thing for 
the same reason.

Auke
