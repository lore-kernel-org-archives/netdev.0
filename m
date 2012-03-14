From: David Miller <davem@davemloft.net>
Subject: Re: [net 2/2] net: fix a bug of dropping FCoE frames when
 disabling tx ip checksum
Date: Wed, 14 Mar 2012 15:17:36 -0700 (PDT)
Message-ID: <20120314.151736.472826877671724625.davem@davemloft.net>
References: <138EA028228D124A900F5E6746F3C2160F6B3176@ORSMSX102.amr.corp.intel.com>
	<20120314.145329.240390897242258725.davem@davemloft.net>
	<138EA028228D124A900F5E6746F3C2160F6B5377@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: yi.zou@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48534 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761165Ab2CNWRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 18:17:42 -0400
In-Reply-To: <138EA028228D124A900F5E6746F3C2160F6B5377@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Zou, Yi" <yi.zou@intel.com>
Date: Wed, 14 Mar 2012 22:04:06 +0000

>> 
>> From: "Zou, Yi" <yi.zou@intel.com>
>> Date: Wed, 14 Mar 2012 20:48:03 +0000
>> 
>> > CHECKSUM_UNNECESSARY sounds good to me, if it's ok to be used on the tx
>> path 
>> > as well, I think so but I am not 100% sure, it'd resolve this for fcoe
>> and sctp
>> > like, downside is it's a bigger change that requires corresponding
>> changes in
>> > these protocol driver stacks as well.
>> 
>> This is definitely the way this bug should be fixed, CHECKSUM_PARTIAL should
>> never be set for packets outside of the domain that value was designed for.
> 
> Cool, then please drop this patch and I will fix this by changing the fcoe 
> protocol stack driver to use CHECKSUM_UNNECESSARY instead.

I've dropped both patches.
