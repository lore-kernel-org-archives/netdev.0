From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 2/5 2.6.22-rc6] L2TP: Changes to existing ppp and socket
 kernel headers for L2TP
Date: Thu, 28 Jun 2007 08:39:57 +0100
Message-ID: <468365CD.7050803@katalix.com>
References: <200706272220.l5RMKcv9004943@quickie.katalix.com> <20070627.154848.112982936.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:57817 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760200AbXF1HkC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 03:40:02 -0400
In-Reply-To: <20070627.154848.112982936.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> This is going to cause problems on compat platforms where
> __u64 is aligned on an 8-byte boundary on the 64-bit
> variant but it is not on the 32-bit cpu variant.
> 
> A way to avoid this is to use the aligned_u64 type from
> linux/types.h which ensures 8-byte alignment on all
> platforms and thus you won't need to provide s compat
> ioctl() handler for your statistics ioctl().

Thanks for the info. I wasn't aware of aligned_u64.

> I'll make this change for you so we don't have to go
> back and forth again just for this.

Thanks!

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

