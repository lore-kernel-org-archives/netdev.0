From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v3 0/3] Enable FEC pps feather
Date: Fri, 10 Oct 2014 09:44:31 +0200
Message-ID: <20141010074431.GA4181@localhost.localdomain>
References: <1412918130-18830-1-git-send-email-b45643@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, shawn.guo@linaro.org,
	bhutchings@solarflare.com, R49496@freescale.com,
	b38611@freescale.com, b20596@freescale.com,
	stephen@networkplumber.org
To: Luwei Zhou <b45643@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:47445 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbaJJHoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 03:44:37 -0400
Received: by mail-wi0-f175.google.com with SMTP id d1so1181961wiv.2
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 00:44:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1412918130-18830-1-git-send-email-b45643@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 10, 2014 at 01:15:27PM +0800, Luwei Zhou wrote:
> Change from v2 to v3:
> 	-Using the default channel 0 to be PPS channel not PTP_PIN_SET/GETFUNC interface.
> 	-Using the linux definition of NSEC_PER_SEC.
> 
> Change from v1 to v2:
> 	- Fix the potential 32-bit multiplication overflow issue.
> 	- Optimize the hareware adjustment code to improve efficiency as Richard suggested
> 	- Use ptp PTP_PIN_SET/GETFUNC interface to set PPS channel not device tree
> 	and add PTP_PF_PPS enumeration
> 	- Modify comments style
> 
> 
> Luwei Zhou (3):
>   net: fec: ptp: Use the 31-bit ptp timer.
>   net: fec: ptp: Use hardware algorithm to adjust PTP counter.
>   net: fec: ptp: Enable PPS output based on ptp clock

Acked-by: Richard Cochran <richardcochran@gmail.com>
