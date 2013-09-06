From: David Miller <davem@davemloft.net>
Subject: Re: [E1000-devel] [net-next v5 8/8] i40e: include i40e in kernel
 proper
Date: Fri, 06 Sep 2013 14:23:02 -0400 (EDT)
Message-ID: <20130906.142302.514119919125432228.davem@davemloft.net>
References: <1378450038.19204.6.camel@joe-AO722>
	<AAEA33E297BCAC4B9BB20A7C2DF0AB8D5C3B0A3D@FMSMSX113.amr.corp.intel.com>
	<1378491615.19204.10.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, jesse.brandeburg@intel.com,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60943 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811Ab3IFSXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 14:23:05 -0400
In-Reply-To: <1378491615.19204.10.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 06 Sep 2013 11:20:15 -0700

> On Fri, 2013-09-06 at 17:28 +0000, Williams, Mitch A wrote:
>> My goal was to make our out-of-tree driver as close as possible -
>> including the makefiles - to the upstream driver. Doing this makes it
>> simpler for us to backport and forward-port patches. It makes it less
>> confusing for us when we're moving from one environment to the other.
> 
> I think using things like
> 
> #define i40e_memset memset
> 
> is just odd.

Agreed, this is rediculous.
