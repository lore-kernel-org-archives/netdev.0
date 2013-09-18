From: Aida Mynzhasova <aida.mynzhasova@skitlab.ru>
Subject: Re: [PATCH] powerpc/83xx: gianfar_ptp: select 1588 clock source through
 dts file
Date: Wed, 18 Sep 2013 20:40:25 +0400
Message-ID: <5239D779.7070504@skitlab.ru>
References: <1379510464-25420-1-git-send-email-aida.mynzhasova@skitlab.ru> <20130918160846.GA4397@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.skitlab.ru ([217.65.220.135]:37433 "EHLO mail.skitlab.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751873Ab3IRQk1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 12:40:27 -0400
In-Reply-To: <20130918160846.GA4397@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18.09.2013 20:08, Richard Cochran wrote:
> On Wed, Sep 18, 2013 at 05:21:04PM +0400, Aida Mynzhasova wrote:
>> IEEE 1588 timer reference clock source is determined through hard-coded
>> value in gianfar_ptp driver by default. This patch allows to select ptp
>> clock source by means of device tree file node.
>>
>> For instance:
>>
>> 	fsl,cksel = <0>;
>>
>> for using external (TSEC_TMR_CLK input) high precision timer
>> reference clock.
>>
>> Other acceptable values:
>>
>> 	<1> : eTSEC system clock
>> 	<2> : eTSEC1 transmit clock
>> 	<3> : RTC clock input
>
> Do the other clock sources even work at all?
>
> We were not able to get them working.
>
> Thanks,
> Richard
>

Hi Richard,

I've tried to use 2 clock sources: external from TSEC_TMR_CLK input (for 
this I had to update multiplexer settings in uboot) and eTSEC system 
clock - counter worked fine with both.

My attempts to use eTSEC1 transmit clock and RTC clock were unsuccessful 
(the system hanged up) irrespective of using hard-coded value or entry 
in dts file.

Thanks.
