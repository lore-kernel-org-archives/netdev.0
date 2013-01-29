From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 2/2] drivers: net:ethernet: cpsw: add support for VLAN
Date: Tue, 29 Jan 2013 18:03:13 +0530
Message-ID: <5107C189.1050604@ti.com>
References: <1359403945-28585-1-git-send-email-mugunthanvnm@ti.com> <1359403945-28585-3-git-send-email-mugunthanvnm@ti.com> <20130129073626.GB18272@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:33335 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753226Ab3A2Mek (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 07:34:40 -0500
In-Reply-To: <20130129073626.GB18272@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/29/2013 1:06 PM, Richard Cochran wrote:
> On Tue, Jan 29, 2013 at 01:42:25AM +0530, Mugunthan V N wrote:
>> @@ -947,6 +1042,10 @@ static const struct net_device_ops cpsw_netdev_ops = {
>>   #ifdef CONFIG_NET_POLL_CONTROLLER
>>   	.ndo_poll_controller	= cpsw_ndo_poll_controller,
>>   #endif
>> +#ifdef VLAN_SUPPORT
>> +	.ndo_vlan_rx_add_vid	= cpsw_ndo_vlan_rx_add_vid,
>> +	.ndo_vlan_rx_kill_vid	= cpsw_ndo_vlan_rx_kill_vid,
>> +#endif
> These are not compile time conditionals in net_device_ops, so I wonder
> (after reading Felipe's comments) whether you can simply keep the VLAN
> code always present.
>
> As long as the driver still compiles and loads, when VLAN is missing
> from the stack, then I don't see why you can't just leave it in,
> without all the ifdefs.
>
> Thanks,
> Richard
This idea seems to be good. I will update the patch in next version.

Regards
Mugunthan V N
