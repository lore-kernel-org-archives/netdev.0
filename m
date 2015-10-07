From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Fix vti use case with oif in dst lookups
 for IPv6
Date: Wed, 07 Oct 2015 04:25:25 -0700 (PDT)
Message-ID: <20151007.042525.1310561159530454910.davem@davemloft.net>
References: <1444055571-82546-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbbJGLJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 07:09:40 -0400
In-Reply-To: <1444055571-82546-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon,  5 Oct 2015 08:32:51 -0600

> It occurred to me yesterday that 741a11d9e4103 ("net: ipv6: Add
> RT6_LOOKUP_F_IFACE flag if oif is set") means that xfrm6_dst_lookup
> needs the FLOWI_FLAG_SKIP_NH_OIF flag set. This latest commit causes
> the oif to be considered in lookups which is known to break vti. This
> explains why 58189ca7b274 did not the IPv6 change at the time it was
> submitted.
> 
> Fixes: 42a7b32b73d6 ("xfrm: Add oif to dst lookups")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

If this is needed in v4.3 why are you targetting net-next?

I applied it to both trees...
