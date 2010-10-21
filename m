From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH 12/12] e1000: make e1000_reinit_safe local
Date: Thu, 21 Oct 2010 11:24:39 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.1010211123040.5208@jbrandeb-desk1.amr.corp.intel.com>
References: <20101021175045.625707607@vyatta.com> <20101021175149.150694790@vyatta.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40945 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756836Ab0JUSYk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 14:24:40 -0400
In-Reply-To: <20101021175149.150694790@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 21 Oct 2010, Stephen Hemminger wrote:

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> --- a/drivers/net/e1000/e1000_main.c	2010-10-21 09:35:54.643519367 -0700
> +++ b/drivers/net/e1000/e1000_main.c	2010-10-21 09:36:01.380214771 -0700
> @@ -521,7 +521,7 @@ void e1000_down(struct e1000_adapter *ad
>  	e1000_clean_all_rx_rings(adapter);
>  }
>  
> -void e1000_reinit_safe(struct e1000_adapter *adapter)
> +static void e1000_reinit_safe(struct e1000_adapter *adapter)
>  {
>  	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
>  		msleep(1);
> 

Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

