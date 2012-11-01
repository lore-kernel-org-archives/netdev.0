From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 0/4] Convert blackfin to phc and remove
 timecompare
Date: Thu, 01 Nov 2012 11:43:01 -0400 (EDT)
Message-ID: <20121101.114301.414026192698498641.davem@davemloft.net>
References: <cover.1351696541.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, device-drivers-devel@blackfin.uclinux.org,
	uclinux-dist-devel@blackfin.uclinux.org, lliubbo@gmail.com,
	jacob.e.keller@intel.com, jeffrey.t.kirsher@intel.com,
	john.ronciak@intel.com, john.stultz@linaro.org, vapier@gentoo.org,
	sonic.zhang@analog.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60396 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761922Ab2KAPnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 11:43:04 -0400
In-Reply-To: <cover.1351696541.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Wed, 31 Oct 2012 17:27:21 +0100

> * Changes in V2:
>   - Correct the wrong direction of the shift when converting time
>     stamps to nanoseconds
>   - Add John Stultz's ack on patch 4
> 
> This patch series takes care of a legacy issue in the time keeping
> core by moving blackfin over to PHC model and removing the dubious
> timecompare code.
> 
> The blackfin is quite similar to the other MAC based PTP hardware
> clocks, and so the implementation is straightforward.
> 
> The first patch is a bug fix that should be merged in any
> case. Pacthes two and three convert the bfin_mac to offer a PHC
> device. The last patch removes the timecompare code.

Series applied.
