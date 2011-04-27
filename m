From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH 1/6] Add support for ESP as a separate protocol
 from AH
Date: Wed, 27 Apr 2011 16:47:14 +0100
Message-ID: <1303919234.2875.5.camel@bwh-desktop>
References: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>
	 <20110421204020.23054.60822.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:59215 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755891Ab1D0PrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 11:47:17 -0400
In-Reply-To: <20110421204020.23054.60822.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-04-21 at 13:40 -0700, Alexander Duyck wrote:
> This change is mostly cosmetic.  NIU had supported AH and ESP seperately.
> As such it is possible that a return value of ESP or AH may be returned
> for a has request instead of the AH_ESP combined value.  To resolve that
> the inputs are combined for AH and ESP into the AH_ESP value and return
> values for AH and ESP will display the combined string info.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied, but I moved this into a separate commit:

[...]
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -32,7 +32,6 @@
>  #include <sys/ioctl.h>
>  #include <sys/stat.h>
>  #include <stdio.h>
> -#include <string.h>
>  #include <errno.h>
>  #include <net/if.h>
>  #include <sys/utsname.h>
[...]

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

