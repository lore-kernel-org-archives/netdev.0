From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH] powerpc/83xx: gianfar_ptp: select 1588 clock source through
 dts file
Date: Thu, 19 Sep 2013 19:30:02 +0300
Message-ID: <523B268A.2010805@freescale.com>
References: <1379510464-25420-1-git-send-email-aida.mynzhasova@skitlab.ru> <5239CA4F.9000600@freescale.com> <5239D74F.5030801@skitlab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <richardcochran@gmail.com>, <netdev@vger.kernel.org>
To: Aida Mynzhasova <aida.mynzhasova@skitlab.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.32.181.185] ([216.32.181.185]:54733 "EHLO
	ch1outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751831Ab3ISQbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 12:31:25 -0400
In-Reply-To: <5239D74F.5030801@skitlab.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 9/18/2013 7:39 PM, Aida Mynzhasova wrote:
> On 18.09.2013 19:44, Claudiu Manoil wrote:
>>
>> On 9/18/2013 4:21 PM, Aida Mynzhasova wrote:
>>> IEEE 1588 timer reference clock source is determined through hard-coded
>>> value in gianfar_ptp driver by default. This patch allows to select ptp
>>> clock source by means of device tree file node.
>>>
>>> For instance:
>>>
>>>     fsl,cksel = <0>;
>>>
>>
>> Has this device tree binding been defined? (Where?)
>> I don't see this property in the net-next.git tree at least.
>>
>> Claudiu
>>
>>
>
> Hi Claudiu,
>
> actually, I don't know where I should define this binding, my only idea
> is to add "cksel" property description in
> /Documentation/devicetree/bindings/net/fsl-tsec-phy.txt. Am I right or I
> need to do some additional changes?
>
> Thanks.
>
>


If you ask me, updates for the device trees of several powerpc boards, 
like the 83xx series (as this patch implies), should be discussed and 
agreed upon on the powerpc list (linuxppc-dev@lists.ozlabs.org),
where these kind of changes are usually being discussed with people more
knowledgeable in device tree bindings and the powerpc/83xx hardware.

Regards,
Claudiu
