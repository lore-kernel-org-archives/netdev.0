From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pch_gbe, ptp_pch: Fix the dependency
 direction between these drivers
Date: Sat, 17 Nov 2012 22:12:20 -0500 (EST)
Message-ID: <20121117.221220.439160764788131857.davem@davemloft.net>
References: <1353116639.2743.88.camel@bwh-desktop.uk.solarflarecom.com>
	<50A6F01C.4010304@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	tshimizu818@gmail.com, richardcochran@gmail.com
To: rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44434 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527Ab2KRDMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2012 22:12:22 -0500
In-Reply-To: <50A6F01C.4010304@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Fri, 16 Nov 2012 18:02:04 -0800

> On 11/16/2012 05:43 PM, Ben Hutchings wrote:
> 
>> In commit a24006ed12616bde1bbdb26868495906a212d8dc ('ptp: Enable clock
>> drivers along with associated net/PHY drivers') I wrongly made
>> PTP_1588_CLOCK_PCH depend on PCH_GBE.  The dependency is really the
>> other way around.  Therefore make PCH_GBE select PTP_1588_CLOCK_PCH
>> and remove the 'default y' from the latter.
>> 
>> Reported-by: Randy Dunlap <rdunlap@xenotime.net>
>> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> 
> Acked-by: Randy Dunlap <rdunlap@xenotime.net>

Applied, thanks everyone.
