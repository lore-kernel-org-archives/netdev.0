From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/3] Enable FEC pps feather
Date: Tue, 14 Oct 2014 14:45:34 -0400 (EDT)
Message-ID: <20141014.144534.579480584292383456.davem@davemloft.net>
References: <1412918130-18830-1-git-send-email-b45643@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
	shawn.guo@linaro.org, bhutchings@solarflare.com,
	R49496@freescale.com, b38611@freescale.com, b20596@freescale.com,
	stephen@networkplumber.org
To: b45643@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43535 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755371AbaJNSpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 14:45:39 -0400
In-Reply-To: <1412918130-18830-1-git-send-email-b45643@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luwei Zhou <b45643@freescale.com>
Date: Fri, 10 Oct 2014 13:15:27 +0800

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

Series applied, thanks.
