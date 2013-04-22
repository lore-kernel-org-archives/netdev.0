From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 3/5] net/cpsw: don't rely on netif_running() to check
 which device is active
Date: Mon, 22 Apr 2013 10:33:12 +0200
Message-ID: <5174F5C8.5080703@linutronix.de>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de> <1366235536-15744-4-git-send-email-bigeasy@linutronix.de> <51714256.6030504@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org,
	tglx@linutronix.de, "David S. Miller" <davem@davemloft.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:56594 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753536Ab3DVIdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 04:33:15 -0400
In-Reply-To: <51714256.6030504@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2013 03:10 PM, Sergei Shtylyov wrote:
Hello Sergei,

>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -341,6 +341,7 @@ struct cpsw_priv {
>>       int                host_port;
>>       struct clk            *clk;
>>       u8                mac_addr[ETH_ALEN];
>> +    u8                active;
> 
>    *bool* seems to fit better here.

yes but would require the compiler to add an extra pad between u8 and
bool and another between bool and the pointer. That way it does not
cause the struct to grow :) Anyway, v2 is out without the need for it.

> 
> WBR, Sergei
> 

Sebastian
