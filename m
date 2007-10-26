From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] skye/skge: sparse fix - data can't ever be bigger than
 LONG_MAX / HZ
Date: Fri, 26 Oct 2007 15:15:25 -0700
Message-ID: <472266FD.8040005@intel.com>
References: <20071026221028.1873.3005.stgit@localhost.localdomain> <20071026151240.0ce5f7ec@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2283 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752133AbXJZWRY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 18:17:24 -0400
In-Reply-To: <20071026151240.0ce5f7ec@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Fri, 26 Oct 2007 15:10:28 -0700
> Auke Kok <auke-jan.h.kok@intel.com> wrote:
> 
>> Trivial replacement - use INT_MAX instead here.
>>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> Cc: shemminger@linux-foundation.org
> 
> Acked-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Sure that works. Note: original code was copied from e100 which I assume
> is why you found/fixed this case.

I went over your sparse fixes and decided to fix that last warning that you had
not fixed. I thought I might as well fix those poor drivers that copied our
bad-ass code ;)

still testing the code you sent me though... hopefully not much longer.

Auke
