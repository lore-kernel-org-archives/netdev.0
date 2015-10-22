From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Really fix vti6 with oif in dst lookups
Date: Wed, 21 Oct 2015 19:05:19 -0700 (PDT)
Message-ID: <20151021.190519.1411457946955175451.davem@davemloft.net>
References: <1445268365-23414-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49801 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932397AbbJVBsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 21:48:53 -0400
In-Reply-To: <1445268365-23414-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 19 Oct 2015 08:26:05 -0700

> 6e28b000825d ("net: Fix vti use case with oif in dst lookups for IPv6")
> is missing the checks on FLOWI_FLAG_SKIP_NH_OIF. Add them.
> 
> Fixes: 42a7b32b73d6 ("xfrm: Add oif to dst lookups")
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks.
