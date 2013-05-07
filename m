From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH v2 1/8] net: sh-eth: Remove ifdef from definition of bit of
 EDSR and GECMR
Date: Tue, 07 May 2013 11:57:25 +0900
Message-ID: <51886D95.8020603@renesas.com>
References: <1366279869-23387-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <51700850.3050906@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor4.renesas.com ([210.160.252.174]:44069 "EHLO
	relmlor4.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757007Ab3EGC51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 22:57:27 -0400
Received: from relmlir3.idc.renesas.com ([10.200.68.153])
 by relmlor4.idc.renesas.com ( SJSMS)
 with ESMTP id <0MME007AOQVQW260@relmlor4.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 11:57:26 +0900 (JST)
Received: from relmlac1.idc.renesas.com ([10.200.69.21])
 by relmlir3.idc.renesas.com ( SJSMS)
 with ESMTP id <0MME00HEVQVPIUD0@relmlir3.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 11:57:26 +0900 (JST)
In-reply-to: <51700850.3050906@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

(2013/04/18 23:50), Sergei Shtylyov wrote:
> On 18-04-2013 14:11, Nobuhiro Iwamatsu wrote:
>
>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>
> Step in the right direction.
>
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
>> index 6f9a997..f86ea96 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.h
>> +++ b/drivers/net/ethernet/renesas/sh_eth.h
>> @@ -166,19 +166,16 @@ enum {
>> /*
>> * Register's bits
>> */
>> -#if defined(CONFIG_CPU_SUBTYPE_SH7734) || defined(CONFIG_CPU_SUBTYPE_SH7763) ||\
>> - defined(CONFIG_ARCH_R8A7740)
>> -/* EDSR */
>> +/* EDSR : sh7734, sh7764, sh7757 and r8a7740 only */
>
> Where sh7764 and sh7757 came from?

sh7764 is wrong. I will fix to sh7763.
sh7757 has this register. I will split to other patch about this.

>
>> enum EDSR_BIT {
>> EDSR_ENT = 0x01, EDSR_ENR = 0x02,
>> };
>> #define EDSR_ENALL (EDSR_ENT|EDSR_ENR)
>>
>> -/* GECMR */
>> +/* GECMR : sh7734, sh7764 and r8a7740 only */
>
> Where sh7764 came from?

This is same too. thanks.

>
>> enum GECMR_BIT {
>> GECMR_10 = 0x0, GECMR_100 = 0x04, GECMR_1000 = 0x01,
>> };
>> -#endif
>
> WBR, Sergei
>

Best regards,
   Nobuhiro
