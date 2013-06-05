From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH v2] net: sh-eth: Add flag to determine the type of TSU
 register
Date: Wed, 05 Jun 2013 14:12:42 +0900
Message-ID: <51AEC8CA.9070009@renesas.com>
References: <1367903291-32323-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <51891350.9060700@cogentembedded.com> <51AE21B4.4000907@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor4.renesas.com ([210.160.252.174]:39663 "EHLO
	relmlor4.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466Ab3FEFMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 01:12:45 -0400
Received: from relmlir3.idc.renesas.com ([10.200.68.153])
 by relmlor4.idc.renesas.com ( SJSMS)
 with ESMTP id <0MNW007MBMH77U40@relmlor4.idc.renesas.com> for
 netdev@vger.kernel.org; Wed, 05 Jun 2013 14:12:43 +0900 (JST)
Received: from relmlac3.idc.renesas.com ([10.200.69.23])
 by relmlir3.idc.renesas.com ( SJSMS)
 with ESMTP id <0MNW00AQ6MH7EO90@relmlir3.idc.renesas.com> for
 netdev@vger.kernel.org; Wed, 05 Jun 2013 14:12:43 +0900 (JST)
In-reply-to: <51AE21B4.4000907@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

(2013/06/05 2:19), Sergei Shtylyov wrote:
> Hello.
>
> On 05/07/2013 06:44 PM, I wrote:
>
>> You shouldn't have posted this patch (and the subsequent series) during the merge window, as David will probably tell you.
>>
>> On 07-05-2013 9:08, Nobuhiro Iwamatsu wrote:
>>
>>> Some sh-eth devices may have two ether devices inside.
>>
>> You probably meant to say: "some SoCs may have two Ether devices inside".
>>
>>> And the function of TSU is accessed from each ether device.
>>> In this case, sh-eth need to remap address using devm_ioremap(),
>>> without using devm_ioremap_resource().
>>
>> You could use devm_ioremap_resource() for the 1st Ether instance, and devm_ioremap() for the 2nd, couldn't you?
>

Yes, hmm. I will rewrite this patch.

> Wait, you can't have the same resource on both platform devices, that's a resource conflict.

yes, therefore, we are using lock in sh_eth_set_multicast_list function.

>
>>
>>> tsu_shared_reg of sh_eth_cpu_data is used for this control.
>>
>>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>>
>
> WBR, Sergei
>
>

Best regards,
   Nobuhiro
