From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 3/5] net/cpsw: don't rely on netif_running() to check
 which device is active
Date: Thu, 18 Apr 2013 14:10:21 +0200
Message-ID: <516FE2AD.2040403@linutronix.de>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de> <1366235536-15744-4-git-send-email-bigeasy@linutronix.de> <516FDE0A.70504@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tglx@linutronix.de,
	"David S. Miller" <davem@davemloft.net>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:44301 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755213Ab3DRMKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 08:10:23 -0400
In-Reply-To: <516FDE0A.70504@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/18/2013 01:50 PM, Mugunthan V N wrote:

>> diff --git a/drivers/net/ethernet/ti/cpsw.c
>> b/drivers/net/ethernet/ti/cpsw.c
>> index 3b22a36..c32780d 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -341,6 +341,7 @@ struct cpsw_priv {
>>       int                host_port;
>>       struct clk            *clk;
>>       u8                mac_addr[ETH_ALEN];
>> +    u8                active;
> Frame work is providing this feature then why you need to have additional
> book keeping in device private?

Which function? I more than happy to use it.

> 
> Regards
> Mugunthan V N

Sebastian
