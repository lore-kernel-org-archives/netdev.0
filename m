From: David Miller <davem@davemloft.net>
Subject: Re: [IPROUTE PATCH] libnetlink: Use ifinfomsg instead of rtgenmsg
 in rtnl_wilddump_req_filter
Date: Thu, 25 Apr 2013 19:22:20 -0400 (EDT)
Message-ID: <20130425.192220.142182130759939239.davem@davemloft.net>
References: <20130425220710.6520.32515.stgit@ahduyck-cp1.jf.intel.com>
	<20130425161703.2a78ebd7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, ogerlitz@mellanox.com,
	jeffrey.t.kirsher@intel.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932096Ab3DYXWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 19:22:21 -0400
In-Reply-To: <20130425161703.2a78ebd7@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 25 Apr 2013 16:17:03 -0700

> On Thu, 25 Apr 2013 15:07:10 -0700
> Alexander Duyck <alexander.h.duyck@intel.com> wrote:
> 
>> This change corrects a kernel incompatibility that was resulting in the
>> ext_filter_mask not being correctly discovered by the kernel as it is buried
>> somewhere in the ifinfomsg.
>> 
>> Reported-by: Or Gerlitz <ogerlitz@mellanox.com>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This looks good, I will apply it unless there are objections.

Same here:

Acked-by: David S. Miller <davem@davemloft.net>
