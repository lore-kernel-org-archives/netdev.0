From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH v2 5/8] net: sh-eth: Add CONFIG_PM to definition of
 dev_pm_ops
Date: Tue, 07 May 2013 11:57:47 +0900
Message-ID: <51886DAB.60804@renesas.com>
References: <1366279869-23387-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <1366279869-23387-5-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <517008D5.8020309@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor2.renesas.com ([210.160.252.172]:40630 "EHLO
	relmlor2.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758459Ab3EGC5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 22:57:48 -0400
Received: from relmlir4.idc.renesas.com ([10.200.68.154])
 by relmlor2.idc.renesas.com ( SJSMS)
 with ESMTP id <0MME00BEAQWBG760@relmlor2.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 11:57:47 +0900 (JST)
Received: from relmlac4.idc.renesas.com ([10.200.69.24])
 by relmlir4.idc.renesas.com ( SJSMS)
 with ESMTP id <0MME00HV9QWBPHA0@relmlir4.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 11:57:47 +0900 (JST)
In-reply-to: <517008D5.8020309@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

(2013/04/18 23:53), Sergei Shtylyov wrote:
> On 18-04-2013 14:11, Nobuhiro Iwamatsu wrote:
>
>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> [...]
>
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
>> index 7de0b0e..af8c225 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> [...]
>> @@ -2785,17 +2786,21 @@ static int sh_eth_runtime_nop(struct device *dev)
>> return 0;
>> }
>>
>> -static struct dev_pm_ops sh_eth_dev_pm_ops = {
>> +static const struct dev_pm_ops sh_eth_dev_pm_ops = {
>> .runtime_suspend = sh_eth_runtime_nop,
>> .runtime_resume = sh_eth_runtime_nop,
>> };
>> +#define SH_ETH_PM_OPS &sh_eth_dev_pm_ops
>
> scripts/checkpatch.pl would complain here about missing (), I heard.
> Did you run it?

thanks, it had missed, although I was running.
I will fix this.

Best regards,
   Nobuhiro
