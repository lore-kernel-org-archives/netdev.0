From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Fri, 15 Jul 2016 11:29:51 -0700 (PDT)
Message-ID: <20160715.112951.865048162043566247.davem@davemloft.net>
References: <20160714152215.GA24590@u54ee753d2d1854bda401.ant.amazon.com>
	<20160714160803.egrmos7soc6qvrry@f1.synalogic.ca>
	<20160714161511.GA30697@u54ee753d2d1854bda401.ant.amazon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benjamin.poirier@gmail.com, netanel@annapurnalabs.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	zorik@annapurnalabs.com, saeed@annapurnalabs.com,
	alex@annapurnalabs.com, aliguori@amazon.com, ben@decadent.org.uk,
	romieu@fr.zoreil.com, rami.rosen@intel.com,
	antoine.tenart@free-electrons.com, linville@tuxdriver.com
To: msw@amzn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbcGOS3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 14:29:55 -0400
In-Reply-To: <20160714161511.GA30697@u54ee753d2d1854bda401.ant.amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Wilson <msw@amzn.com>
Date: Thu, 14 Jul 2016 09:15:11 -0700

> On Thu, Jul 14, 2016 at 09:08:03AM -0700, Benjamin Poirier wrote:
>> On 2016/07/14 08:22, Matt Wilson wrote:
>> [...]
>> > 
>> > Dave and Benjamin,
>> > 
>> > Do you want to see the interrupt moderation extensions to ethtool and
>> > the sysfs nodes removed before this lands in net-next? Or should
>> > Netanel remove the sysfs bits until we can extend the ethtool
>> > interfaces to cover the parameters that ena uses?
>> 
>> I couldn't say what's acceptable or not. A few other drivers (qlcnic,
>> sfc, ...) already have sysfs tunables. Maybe John, as the new ethtool
>> maintainer, can weight in too about the changes required to ethtool.
> 
> We definitely want ethtool to handle all the settings, it's just a
> question of when. We also want to address and resolve all the great
> feedback so far, and since you originally raised the point about
> extending ethtool I wanted to see if you have any major objection.

If you add the sysfs stuff you're stuck with it forever, so I definitely
do not want to see that.

You guys should start simple, a basic driver that supports what is
possible with no core kernel changes or non-portable driver private
sysfs knobx.  Only then should you think about adding new things.
