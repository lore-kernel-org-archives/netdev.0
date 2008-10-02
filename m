From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [PATCH] e1000e: write protect ICHx NVM to prevent malicious write/erase
Date: Wed, 01 Oct 2008 18:33:31 -0700
Message-ID: <48E424EB.1000204@linux.intel.com>
References: <20081002001830.5951.3123.stgit@jbrandeb-bw.jf.intel.com> <20081002001835.5951.82533.stgit@jbrandeb-bw.jf.intel.com> <alpine.LFD.2.00.0810011731350.3341@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>, jeff@garzik.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:25140 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751807AbYJBBdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 21:33:40 -0400
In-Reply-To: <alpine.LFD.2.00.0810011731350.3341@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus Torvalds wrote:
> 
> On Wed, 1 Oct 2008, Jesse Brandeburg wrote:
>> From: Bruce Allan <bruce.w.allan@intel.com>
>>
>> Set the hardware to ignore all write/erase cycles to the GbE region in
>> the ICHx NVM.  This feature can be disabled by the WriteProtectNVM module
>> parameter (enabled by default) only after a hardware reset, but
>> the machine must be power cycled before trying to enable writes.
> 
> Thanks, applied.
> 
> One thing that I did notice when I looked at the driver is that I don't 
> see any serialization what-so-ever around a lot of the special accesses.
> 

there's quite a few of that yes.
These are all fixed afaik but these fixes are being queued for 2.6.28 rather than being snuck in late into .27
(the patches have been posted to lkml a few times the last week)
