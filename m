From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Fix continued iteration in
 rtnl_bridge_getlink()
Date: Fri, 02 Nov 2012 21:54:04 -0400 (EDT)
Message-ID: <20121102.215404.1294793435449363791.davem@davemloft.net>
References: <1351897012.2703.17.camel@bwh-desktop.uk.solarflarecom.com>
	<5094766B.1000407@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49451 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763290Ab2KCByG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 21:54:06 -0400
In-Reply-To: <5094766B.1000407@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Fri, 02 Nov 2012 18:42:03 -0700

> On 11/2/2012 3:56 PM, Ben Hutchings wrote:
>> Commit e5a55a898720096f43bc24938f8875c0a1b34cd7 ('net: create generic
>> bridge ops') broke the handling of a non-zero starting index in
>> rtnl_bridge_getlink() (based on the old br_dump_ifinfo()).
>>
>> When the starting index is non-zero, we need to increment the current
>> index for each entry that we are skipping.  Also, we need to check the
>> index before both cases, since we may previously have stopped
>> iteration between getting information about a device from its master
>> and from itself.
>>
>> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
>> ---
> 
> I needed to be testing with more interfaces. Its clearly broke
> with >41 veth devices. This patch fixes it thanks a lot Ben!
> 
> Tested-by: John Fastabend <john.r.fastabend@intel.com>

Applied, thanks everyone.

 
