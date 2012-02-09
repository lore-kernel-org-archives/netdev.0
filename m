From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] rtnetlink: Add filter for VF info dump requests
Date: Thu, 09 Feb 2012 13:49:40 -0500 (EST)
Message-ID: <20120209.134940.176223015646381142.davem@davemloft.net>
References: <C5551D9AAB213A418B7FD5E4A6F30A0702F86E01@ORSMSX106.amr.corp.intel.com>
	<20120209.134347.615561064709168825.davem@davemloft.net>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F874CA@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57237 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239Ab2BIStm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 13:49:42 -0500
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0702F874CA@ORSMSX106.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Date: Thu, 9 Feb 2012 18:45:59 +0000

>> -----Original Message-----
>> From: David Miller [mailto:davem@davemloft.net]
>> Sent: Thursday, February 09, 2012 10:44 AM
>> To: Rose, Gregory V
>> Cc: netdev@vger.kernel.org
>> Subject: Re: [RFC PATCH] rtnetlink: Add filter for VF info dump requests
>> 
>> From: "Rose, Gregory V" <gregory.v.rose@intel.com>
>> Date: Thu, 9 Feb 2012 16:25:31 +0000
>> 
>> > That will change the semantics to the 'ip link show' command quite a
>> bit.
>> 
>> I think that's rubbish.
>> 
>> You can make "ip link show" do whatever you want, including setting all
>> feature bits in getlink requests, which will preserve existing behavior.
> 
> But there will be a change to the command line semantics no?  How do
> I communicate which feature bits to set in getlink requests
> otherwise?

Make "ip" internally default to "all" feature bits.  I don't really
understand what the consternation is.  Right now, that's what happens,
the kernel dumps all the attributes including "VF" stuff.
