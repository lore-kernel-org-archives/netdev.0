From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 3/5] net/cpsw: don't rely on netif_running() to check
 which device is active
Date: Fri, 19 Apr 2013 16:05:55 +0530
Message-ID: <51711E0B.4000306@ti.com>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de> <1366235536-15744-4-git-send-email-bigeasy@linutronix.de> <516FDE0A.70504@ti.com> <516FE2AD.2040403@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:42202 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756967Ab3DSKgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 06:36:11 -0400
In-Reply-To: <516FE2AD.2040403@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/18/2013 5:40 PM, Sebastian Andrzej Siewior wrote:
> On 04/18/2013 01:50 PM, Mugunthan V N wrote:
>
>>> diff --git a/drivers/net/ethernet/ti/cpsw.c
>>> b/drivers/net/ethernet/ti/cpsw.c
>>> index 3b22a36..c32780d 100644
>>> --- a/drivers/net/ethernet/ti/cpsw.c
>>> +++ b/drivers/net/ethernet/ti/cpsw.c
>>> @@ -341,6 +341,7 @@ struct cpsw_priv {
>>>        int                host_port;
>>>        struct clk            *clk;
>>>        u8                mac_addr[ETH_ALEN];
>>> +    u8                active;
>> Frame work is providing this feature then why you need to have additional
>> book keeping in device private?
> Which function? I more than happy to use it.
>
The same netif_running(). But why you are telling not to rely on this API?
device state is updated immediately after successful ndo_open.

Regards
Mugunthan V N
