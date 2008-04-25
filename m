From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/8] e1000e: cleanup several stats issues
Date: Fri, 25 Apr 2008 09:39:18 -0700
Message-ID: <48120936.2060308@intel.com>
References: <20080423180900.24972.84015.stgit@localhost.localdomain> <481173B9.3010006@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23507 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757276AbYDYQjU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 12:39:20 -0400
In-Reply-To: <481173B9.3010006@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Auke Kok wrote:
>> From: Bruce Allan <bruce.w.allan@intel.com>
>>
>> Several stats registers are completely unused and we just waste pci
>> bus time reading them. We also omit using the high 32 bits of the GORC/
>> GOTC counters. We can just read clear them and only read the low
>> registers.
>>
>> Mii-tool can also break es2lan if it executes a MII PHY register
>> ioctl while the device is in autonegotiation. Unfortunately it seems
>> that several applications and installations still perform this ioctl
>> call periodically and especially in this crucial startup time. We
>> can fool the ioctl by providing fail safe information that mimics
>> the "down" link state and only perform the dangerous PHY reads once
>> after link comes up to fill in the real values. As long as link
>> stays up the information will not change.
>>
>> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> 
> applied 1-8
> 
> I was mainly waiting for the discussion of the abuse of the ethtool
> interface, which I chose to allow.
> 
> Now, send me a patch to the ethtool man page for this new behavior :)

agreed - I'll come up with an appropriate explanation to cover this issue.

Thanks.

Auke


