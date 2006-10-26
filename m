From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] Rewrite e100_phys_id
Date: Thu, 26 Oct 2006 13:04:32 -0700
Message-ID: <454114D0.6050900@intel.com>
References: <20061026191154.GG5591@parisc-linux.org> <20061026191937.GB11312@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matthew Wilcox <matthew@wil.cx>, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17048 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S1423484AbWJZUGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 16:06:33 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <20061026191937.GB11312@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> On Thu, Oct 26, 2006 at 01:11:55PM -0600, Matthew Wilcox wrote:
>> The motivator for this was to fix the sparse warning:
>>
>> drivers/net/e100.c:2418:48: warning: cast truncates bits from constant
>> value (83126e978d4fdf becomes 978d4fdf)
>> drivers/net/e100.c:2419:37: warning: cast truncates bits from constant
>> value (83126e978d4fdf becomes 978d4fdf)
>>
>> Initially, I tried a quick fix, but when it ran into difficulties, I
>> looked at tg3.c to see how it does it.  I liked their way better, so I
>> rewrote e100.c to be similar.  It shaves ~700 bytes off the size of the
>> driver, and a few bytes off the size of struct nic, so I think it's a
>> win all round.  Tested on the internal interface of an HP Integrity rx2600.
>>
>> Signed-off-by: Matthew Wilcox <matthew@wil.cx>
> 
> Seems sane to me...  I'll pick it up, if Auke doesn't...

no objections, so I'll ACK it with the notion that I'm going to let our labs do some 
more testing on it with all the latest changes to it.

Jeff, I will stack it on the patches I have for 2.6.20 and push those out before the 
weekend.

Cheers,

Auke
