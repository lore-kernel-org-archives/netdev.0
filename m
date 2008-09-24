From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 2/3] e1000e: Useset_memory_ro()/set_memory_rw() to protect
 flash memory
Date: Wed, 24 Sep 2008 12:51:01 +0200
Message-ID: <48DA1B95.5030806@s5r6.in-berlin.de>
References: <20080923224535.6869.76210.stgit@jtkirshe-mobile.jf.intel.com>	<20080923.162957.141669474.davem@davemloft.net>	<Pine.LNX.4.64.0809240142030.27884@twin.jikos.cz> <20080923.164745.12711639.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jkosina@suse.cz, jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	mingo@elte.hu, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, bruce.w.allan@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:32894 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbYIXKxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 06:53:35 -0400
In-Reply-To: <20080923.164745.12711639.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jiri Kosina <jkosina@suse.cz>
> Date: Wed, 24 Sep 2008 01:45:53 +0200 (CEST)
> 
>> Yes, probably not a vanilla kernel material, but could be very well used 
>> for testing to further isolate whether it is kernel or userspace 
>> corrupting the memory mapped eeprom.
> 
> Absolutely.

Would it help and would it be feasible to drastically shorten the 
lifetime of the MMIO mapping?  I.e. only have it mapped briefly during 
the driver probe, and temporarily whenever a userspace tool like ethtool 
needs it.
-- 
Stefan Richter
-=====-==--- =--= ==---
http://arcgraph.de/sr/
