From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] net: sh-eth: Add flag to determine the type of TSU
 register
Date: Tue, 04 Jun 2013 21:19:48 +0400
Message-ID: <51AE21B4.4000907@cogentembedded.com>
References: <1367903291-32323-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com> <51891350.9060700@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:63705 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738Ab3FDRTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 13:19:48 -0400
Received: by mail-lb0-f176.google.com with SMTP id z5so935253lbh.7
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 10:19:46 -0700 (PDT)
In-Reply-To: <51891350.9060700@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/07/2013 06:44 PM, I wrote:

>    You shouldn't have posted this patch (and the subsequent series) 
> during the merge window, as David will probably tell you.
>
> On 07-05-2013 9:08, Nobuhiro Iwamatsu wrote:
>
>> Some sh-eth devices may have two ether devices inside.
>
>    You probably meant to say: "some SoCs may have two Ether devices 
> inside".
>
>> And the function of TSU is accessed from each ether device.
>> In this case, sh-eth need to remap address using devm_ioremap(),
>> without using devm_ioremap_resource().
>
>    You could use devm_ioremap_resource() for the 1st Ether instance, 
> and devm_ioremap() for the 2nd, couldn't you?

     Wait, you can't have the same resource on both platform devices, 
that's a resource conflict.

>
>> tsu_shared_reg of sh_eth_cpu_data is used for this control.
>
>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>

WBR, Sergei
