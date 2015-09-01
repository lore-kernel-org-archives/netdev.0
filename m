From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3] net: Make table id type u32
Date: Tue, 1 Sep 2015 13:37:03 -0700
Message-ID: <6C55B581-0BCB-45A3-ACEE-238B3A2A83B7@cumulusnetworks.com>
References: <1441139195-29900-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34745 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbbIAUhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 16:37:07 -0400
Received: by padhy1 with SMTP id hy1so6849734pad.1
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 13:37:06 -0700 (PDT)
In-Reply-To: <1441139195-29900-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Sep 1, 2015, at 1:26 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> 
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
> 
> include/net/route.h        |  2 +-
> include/net/vrf.h          | 24 ++++++++++++------------
> include/trace/events/fib.h |  6 +++---
> net/ipv4/af_inet.c         |  2 +-
> net/ipv4/fib_frontend.c    | 10 +++++-----
> net/ipv4/fib_semantics.c   |  2 +-
> 6 files changed, 23 insertions(+), 23 deletions(-)

Thanks!
Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
