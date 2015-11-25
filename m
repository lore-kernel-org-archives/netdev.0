From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 06/16] i40e: Properly cast type for arithmetic
Date: Tue, 24 Nov 2015 20:57:29 -0500 (EST)
Message-ID: <20151124.205729.1005974063494742153.davem@davemloft.net>
References: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1448409886-90686-7-git-send-email-jeffrey.t.kirsher@intel.com>
	<1448412212.20113.12.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, helin.zhang@intel.com,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752871AbbKYB5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 20:57:35 -0500
In-Reply-To: <1448412212.20113.12.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 24 Nov 2015 16:43:32 -0800

> On Tue, 2015-11-24 at 16:04 -0800, Jeff Kirsher wrote:
>> From: Helin Zhang <helin.zhang@intel.com>
>> 
>> Pointer of type void * shouldn't be used in arithmetic, which may
>> result in compilation error. Casting of (u8 *) can be added to fix
>> that.
>> 
> 
> void * arithmetic is used quite frequently in the kernel.
> 
> What compiler emits an error?

Agreed, "void *" arithmetic should work universally with all compilers
used to build the kernel, otherwise so much crap would break.
