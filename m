From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] bond: add support to read speed and duplex
 via ethtool
Date: Fri, 19 Apr 2013 16:52:20 -0400 (EDT)
Message-ID: <20130419.165220.95208860745202351.davem@davemloft.net>
References: <1366159560-14671-1-git-send-email-andy@greyhouse.net>
	<1366212866.2752.0.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47880 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754450Ab3DSUw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 16:52:26 -0400
In-Reply-To: <1366212866.2752.0.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 17 Apr 2013 16:34:26 +0100

> On Tue, 2013-04-16 at 20:46 -0400, Andy Gospodarek wrote:
>> This patch adds support for the get_settings ethtool op to the bonding
>> driver.  This was motivated by users who wanted to get the speed of the
>> bond and compare that against throughput to understand utilization.
>> The behavior before this patch was added was problematic when computing
>> line utilization after trying to get link-speed and throughput via SNMP.
>> 
>> Output from ethtool looks like this for a round-robin bond:
>> 
>> Settings for bond0:
>> 	Supported ports: [ ]
>> 	Supported link modes:   Not reported
>> 	Supported pause frame use: No
>> 	Supports auto-negotiation: No
>> 	Advertised link modes:  Not reported
>> 	Advertised pause frame use: No
>> 	Advertised auto-negotiation: No
>> 	Speed: 11000Mb/s
>> 	Duplex: Full
>> 	Port: Other
>> 	PHYAD: 0
>> 	Transceiver: internal
>> 	Auto-negotiation: off
>> 	MDI-X: Unknown
>> 	Link detected: yes
>> 
>> I tested this and verified it works as expected.  A test was also done
>> on a version backported to an older kernel and it worked well there.
>> 
>> v2: Switch to using ethtool_cmd_speed_set to set speed, added check to
>> SLAVE_IS_OK for each slave in bond, dropped mode-specific calculations
>> as they were not needed, and set port type to 'Other.'
>> 
>> v3: Fix useless assignment and checkpatch warning.
>> 
>> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> 
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks.
