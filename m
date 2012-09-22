From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net-next 0/4] Two new PTP Hardware Clock features
Date: Sat, 22 Sep 2012 15:43:34 -0400 (EDT)
Message-ID: <20120922.154334.1781240216569115874.davem@davemloft.net>
References: <cover.1348332940.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	jacob.e.keller@intel.com, jeffrey.t.kirsher@intel.com,
	john.stultz@linaro.org, matthew.vick@intel.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34768 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179Ab2IVTng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 15:43:36 -0400
In-Reply-To: <cover.1348332940.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Sat, 22 Sep 2012 19:02:00 +0200

> This patch series adds two new features to the PHC code.
> 
> * ChangeLog
> ** V3
>    - Use the correct parent device in the solarflare driver.
>    - Expand the sysfs documentation of clock_name.
>    - Also document the clock_name field in the header file.
> ** V2 
>    - Preserves the clock_name attribute as it was meant to be, instead
>      of making any changes to it.
>    - Covers the registration API change in the brand new solarflare phc
>      device, which was overlooked in V1.
> 
> The first two patches let a user program find out the previously
> dialed frequency adjustment. This is primarily useful when restarting
> a PTP service, since without this information, the presumably correct
> adjustment will bias the new frequency estimation.
> 
> The third patch links the phc class device to its parent device within
> the driver model and sysfs.
> 
> The fourth patch adds a bit more documentation of the sysfs clock_name
> attribute. This should help clarify the naming scheme.

All applied, with a minor coding style correction made to patch #2

Thanks.
