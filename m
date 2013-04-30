From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/4] be2net: Fix ethtool get drvinfo
Date: Tue, 30 Apr 2013 15:52:01 -0400 (EDT)
Message-ID: <20130430.155201.2039547623230450224.davem@davemloft.net>
References: <6ecf8164-2cef-4a5a-9a18-5c1ba2c41f7c@CMEXHTCAS2.ad.emulex.com>
	<1367328131.5106.62.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: somnath.kotur@emulex.com, netdev@vger.kernel.org,
	kalesh.purayil@emulex.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52720 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932742Ab3D3TwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 15:52:03 -0400
In-Reply-To: <1367328131.5106.62.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 30 Apr 2013 14:22:11 +0100

> On Tue, 2013-04-30 at 17:07 +0530, Somnath Kotur wrote:
>> From: Kalesh AP <kalesh.purayil@emulex.com>
>> 
>> Cannot issue any other mailbox command while firmware download is in progress.
>> The get_drvinfo ethtool hook can be invoked without acquiring any rtnl_lock.
> [...]
> 
> Although I documented that as being possible in ethtool.h, that was only
> because of one particular caller that has since been removed (commit
> e52ac3398c3d 'net: Use device model to get driver name in
> skb_gso_segment()').  So unless I missed another case, you could change
> the documentation.

Please address Ben's feedback and resubmit this series, thanks.
