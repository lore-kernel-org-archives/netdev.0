From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch 1/2] qlcnic: clean up qlcnic_init_pci_info()
Date: Mon, 9 Aug 2010 13:32:54 +0200
Message-ID: <20100809113254.GI9031@bicker>
References: <20100809103542.GG9031@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	linux-driver@qlogic.com, "David S. Miller" <davem@davemloft.net>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:61859 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756199Ab0HILdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 07:33:11 -0400
Content-Disposition: inline
In-Reply-To: <20100809103542.GG9031@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 09, 2010 at 12:36:05PM +0200, Dan Carpenter wrote:
> +err_eswitch:
>  	kfree(adapter->eswitch);
>  	adapter->eswitch = NULL;
> -err_eswitch:
> +err_npars:
>  	kfree(adapter->npars);
> +	adapter->eswitch = NULL;
	^^^^^^^^^^^^^^^^^^^^^^^^

Oops.  Typo.  Will send a corrected fix.  Sorry.

regards,
dan carpenter

>  
>  	return ret;
>  }
