From: Aida Mynzhasova <aida.mynzhasova@skitlab.ru>
Subject: Re: [PATCH] powerpc/83xx: gianfar_ptp: select 1588 clock source through
 dts file
Date: Wed, 18 Sep 2013 20:39:43 +0400
Message-ID: <5239D74F.5030801@skitlab.ru>
References: <1379510464-25420-1-git-send-email-aida.mynzhasova@skitlab.ru> <5239CA4F.9000600@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.skitlab.ru ([217.65.220.135]:37418 "EHLO mail.skitlab.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752951Ab3IRQjq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 12:39:46 -0400
In-Reply-To: <5239CA4F.9000600@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18.09.2013 19:44, Claudiu Manoil wrote:
>
> On 9/18/2013 4:21 PM, Aida Mynzhasova wrote:
>> IEEE 1588 timer reference clock source is determined through hard-coded
>> value in gianfar_ptp driver by default. This patch allows to select ptp
>> clock source by means of device tree file node.
>>
>> For instance:
>>
>>     fsl,cksel = <0>;
>>
>
> Has this device tree binding been defined? (Where?)
> I don't see this property in the net-next.git tree at least.
>
> Claudiu
>
>

Hi Claudiu,

actually, I don't know where I should define this binding, my only idea 
is to add "cksel" property description in 
/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt. Am I right or I 
need to do some additional changes?

Thanks.
