From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dsa: Hide core config options; make drivers
 select what they need
Date: Mon, 26 Nov 2012 17:11:20 -0500 (EST)
Message-ID: <20121126.171120.650732118714345236.davem@davemloft.net>
References: <1353957370.2717.3.camel@bwh-desktop.uk.solarflarecom.com>
	<50B3C8B0.5000308@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	viresh.kumar@linaro.org
To: rdunlap@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755263Ab2KZWLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 17:11:23 -0500
In-Reply-To: <50B3C8B0.5000308@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>
Date: Mon, 26 Nov 2012 11:53:20 -0800

> On 11/26/2012 11:16 AM, Ben Hutchings wrote:
> 
>> Commit 82167cb8c6b2f8166d5c7532e5ef4b5e0cc46a72 ('net: dsa/slave: Fix
>> compilation warnings') fixed one possible invalid configuration
>> (NET_DSA enabled with no trailer formats) but added others: drivers
>> can select NET_DSA without its dependencies being met.
>> 
>> It's not very useful to make either the DSA core or the tagging
>> formats manually selectable without a driver to use them, so:
>> 
>> 1. Define a hidden HAVE_NET_DSA option and move the dependencies of
>>    NET_DSA to that.  While we're at it, drop the deprecated
>>    EXPERIMENTAL dependency.
>> 2. Make NET_DSA and the drivers dependent on HAVE_NET_DSA.
>> 3. Hide the tagging format options again.
>> 4. Make drivers select both NET_DSA and the appropriate tagging format
>>    option.
>> 
>> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> Acked-by: Randy Dunlap <rdunlap@infradead.org>

Applied, thanks everyone.
