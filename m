From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 0/12] qlcnic: patches for new adapter - Qlogic 83XX CNA
Date: Thu,  6 Sep 2012 02:21:57 -0400
Message-ID: <1346912529-17406-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:40757 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751004Ab2IFGjR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2012 02:39:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

>From: David Miller [mailto:davem@davemloft.net]

>From: David Miller [mailto:davem@davemloft.net] 
>Sent: Friday, August 31, 2012 1:05 PM

> +static inline int
> +qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 
> +rate) {
> +	return adapter->nic_ops->config_led(adapter, state, rate);
> +
> +}
> +

>Please get rid of those unnecessary empty lines in the function bodies.

>From: David Miller <davem@davemloft.net>
>Date: Fri, 31 Aug 2012 20:00:35 -0400 (EDT)

>Also in patch #5:
>-	qlcnic_config_ipaddr(adapter, ifa->ifa_address, QLCNIC_IP_UP);
>+	qlcnic_config_ipaddr(adapter, ifa->ifa_address,
>+						 QLCNIC_IP_UP);

>This is not the correct way to format multi-line function calls,
>the correct way is:

>	qlcnic_config_ipaddr(adapter, ifa->ifa_address,
>			     QLCNIC_IP_UP);

I have made the changes as you suggested above.
Please apply the updated 12 patch series to net-next.

Thanks,
Sony
