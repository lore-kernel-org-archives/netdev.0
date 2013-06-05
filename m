From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] net: sh-eth: Add flag to determine the type of TSU
 register
Date: Wed, 05 Jun 2013 18:21:11 +0400
Message-ID: <51AF4957.4030208@cogentembedded.com>
References: <1367903291-32323-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com> <51AD13AD.9090501@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:33906 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060Ab3FEOVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 10:21:12 -0400
Received: by mail-lb0-f174.google.com with SMTP id u10so1958460lbi.19
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 07:21:10 -0700 (PDT)
In-Reply-To: <51AD13AD.9090501@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04-06-2013 2:07, Sergei Shtylyov wrote:

>> Some sh-eth devices may have two ether devices inside.
>> And the function of TSU is accessed from each ether device.
>> In this case, sh-eth need to remap address using devm_ioremap(),
>> without using devm_ioremap_resource().
>> tsu_shared_reg of sh_eth_cpu_data is used for this control.

>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> [...]

>> @@ -2750,7 +2754,12 @@ static int sh_eth_drv_probe(struct
>> platform_device *pdev)
>>               ret = -ENODEV;
>>               goto out_release;
>>           }

>      This patch is not good anymore since in the meanwhile the above
> check got removed.
> Iwamatsu-san, are you going to respin this patch and the next series of
> 9 patches any time
> soon. I need them to base my work on.

    So, I have taken the following series in my own hands and will 
repost it soon. Your authorship will be kept. And I've left this patch 
for you to deal with since I'm not directly interested in it.

WBR, Sergei
