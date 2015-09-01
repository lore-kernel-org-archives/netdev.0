From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: Make table id type u32
Date: Tue, 01 Sep 2015 14:35:00 -0700 (PDT)
Message-ID: <20150901.143500.562734291499403639.davem@davemloft.net>
References: <1441139195-29900-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60888 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbbIAVfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 17:35:04 -0400
In-Reply-To: <1441139195-29900-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue,  1 Sep 2015 14:26:35 -0600

> A number of VRF patches used 'int' for table id. It should be u32 to be
> consistent with the rest of the stack.
> 
> Fixes:
> 4e3c89920cd3a ("net: Introduce VRF related flags and helpers")
> 15be405eb2ea9 ("net: Add inet_addr lookup by table")
> 30bbaa1950055 ("net: Fix up inet_addr_type checks")
> 021dd3b8a142d ("net: Add routes to the table associated with the device")
> dc028da54ed35 ("inet: Move VRF table lookup to inlined function")
> f6d3c19274c74 ("net: FIB tracepoints")
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v3
> - and the printk format specifier (thanks, Nikolay)
> 
> v2
> - update tracepoint as well (thanks, Nikolay)

Applied, thanks.
