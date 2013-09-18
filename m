From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] powerpc/83xx: gianfar_ptp: select 1588 clock source
 through dts file
Date: Wed, 18 Sep 2013 18:08:46 +0200
Message-ID: <20130918160846.GA4397@netboy>
References: <1379510464-25420-1-git-send-email-aida.mynzhasova@skitlab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Aida Mynzhasova <aida.mynzhasova@skitlab.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:56939 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752215Ab3IRQJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 12:09:04 -0400
Received: by mail-ea0-f178.google.com with SMTP id a15so3601529eae.9
        for <netdev@vger.kernel.org>; Wed, 18 Sep 2013 09:09:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1379510464-25420-1-git-send-email-aida.mynzhasova@skitlab.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 18, 2013 at 05:21:04PM +0400, Aida Mynzhasova wrote:
> IEEE 1588 timer reference clock source is determined through hard-coded
> value in gianfar_ptp driver by default. This patch allows to select ptp
> clock source by means of device tree file node.
> 
> For instance:
> 
> 	fsl,cksel = <0>;
> 
> for using external (TSEC_TMR_CLK input) high precision timer
> reference clock.
> 
> Other acceptable values:
> 
> 	<1> : eTSEC system clock
> 	<2> : eTSEC1 transmit clock
> 	<3> : RTC clock input

Do the other clock sources even work at all?

We were not able to get them working.

Thanks,
Richard
