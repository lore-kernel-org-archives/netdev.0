From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] gianfar: fix fiper alignment after resetting the
 time
Date: Sun, 07 Aug 2011 22:53:32 -0700 (PDT)
Message-ID: <20110807.225332.1987773233464471729.davem@davemloft.net>
References: <cover.1312699693.git.richard.cochran@omicron.at>
	<cover.1312699693.git.richard.cochran@omicron.at>
	<018b1f12e792c4758d1e601742f758a09dd10d62.1312699694.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48523 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab1HHFxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 01:53:36 -0400
In-Reply-To: <018b1f12e792c4758d1e601742f758a09dd10d62.1312699694.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Sun,  7 Aug 2011 09:03:03 +0200

> After resetting the time, the PPS signals on the FIPER output channels
> are incorrectly offset from the clock time, as can be readily verified
> by a looping back the FIPER to the external time stamp input.
> 
> Despite its name, setting the "Fiper Realignment Disable" bit seems to
> fix the problem, at least on the P2020.
> 
> Also, following the example code from the Freescale BSP, it is not really
> necessary to disable and re-enable the timer in order to reprogram the
> FIPER. (The documentation is rather unclear on this point. It seems that
> writing to the alarm register also disables the FIPER.)
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> Cc: <stable@kernel.org>

Applied.
