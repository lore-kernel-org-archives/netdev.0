From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH v2 7/8] net: sh-eth: Remove ifdef for sh_eth_select_mii
Date: Tue, 07 May 2013 14:00:40 +0900
Message-ID: <51888A78.4010509@renesas.com>
References: <1366279869-23387-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <1366279869-23387-7-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <517004FD.9060906@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor1.renesas.com ([210.160.252.171]:52797 "EHLO
	relmlor1.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753497Ab3EGFAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 01:00:42 -0400
Received: from relmlir4.idc.renesas.com ([10.200.68.154])
 by relmlor1.idc.renesas.com ( SJSMS)
 with ESMTP id <0MME00BURWL5D2B0@relmlor1.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 14:00:41 +0900 (JST)
Received: from relmlac1.idc.renesas.com ([10.200.69.21])
 by relmlir4.idc.renesas.com ( SJSMS)
 with ESMTP id <0MME00KNWWL5A720@relmlir4.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 14:00:41 +0900 (JST)
In-reply-to: <517004FD.9060906@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

(2013/04/18 23:36), Sergei Shtylyov wrote:
> Hello.
>
> On 18-04-2013 14:11, Nobuhiro Iwamatsu wrote:
>
>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>
> That's what I was going to do first.
>
>> drivers/net/ethernet/renesas/sh_eth.c | 4 ----
>> 1 file changed, 4 deletions(-)
>
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
>> index a4e337f..eb428d4 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
>> @@ -313,9 +313,6 @@ static const u16 sh_eth_offset_fast_sh3_sh2[SH_ETH_MAX_REGISTER_OFFSET] = {
>> [TSU_ADRL31] = 0x01fc,
>> };
>>
>> -#if defined(CONFIG_CPU_SUBTYPE_SH7734) || \
>> - defined(CONFIG_CPU_SUBTYPE_SH7763) || \
>> - defined(CONFIG_ARCH_R8A7740)
>> static void sh_eth_select_mii(struct net_device *ndev)
>
> Don't you want to annotate the function with __maybe_unused?
>
I see.
I will add __maybe_unused. thanks!

Best regards,
   Nobuhiro
