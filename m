From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netfront: report link speed to ethtool
Date: Fri, 18 Nov 2011 14:11:49 -0500 (EST)
Message-ID: <20111118.141149.231957666935653299.davem@davemloft.net>
References: <20111118164805.GA14345@aepfle.de>
	<1321638394.2883.32.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org,
	xen-devel@lists.xensource.com, jeremy.fitzhardinge@citrix.com,
	konrad.wilk@oracle.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46339 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753969Ab1KRTOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 14:14:03 -0500
In-Reply-To: <1321638394.2883.32.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 18 Nov 2011 17:46:34 +0000

> On Fri, 2011-11-18 at 17:48 +0100, Olaf Hering wrote:
>> Add .get_settings function, return fake data so that ethtool can get
>> enough information. For some application like VCS, this is useful,
>> otherwise some of application logic will get panic.
>> The reported data refers to VMWare vmxnet.
>> 
>> Signed-off-by: Xin Wei Hu <xwhu@suse.com>
>> Signed-off-by: Chunyan Liu <cyliu@suse.com>
>> Signed-off-by: Olaf Hering <olaf@aepfle.de>
> 
> NAK, we should not just make things up.

Agreed, if you cannot determine the values with certainty do not
implement this method.

Fix the tools which cannot function without this information.
