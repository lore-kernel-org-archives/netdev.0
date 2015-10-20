From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] net: Really fix vti6 with oif in dst lookups
Date: Tue, 20 Oct 2015 13:01:11 +0200
Message-ID: <20151020110111.GL7701@secunet.com>
References: <1445268365-23414-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:42918 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751651AbbJTLBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Oct 2015 07:01:15 -0400
Content-Disposition: inline
In-Reply-To: <1445268365-23414-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 19, 2015 at 08:26:05AM -0700, David Ahern wrote:
> 6e28b000825d ("net: Fix vti use case with oif in dst lookups for IPv6")
> is missing the checks on FLOWI_FLAG_SKIP_NH_OIF. Add them.
> 
> Fixes: 42a7b32b73d6 ("xfrm: Add oif to dst lookups")
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> This is needed for net in 4.3. 6e28b000825d was mistakenly created on
> top of the VRF patches which had this change. Steffen has confirmed
> VTI6 works with this change.

Acked-by: Steffen Klassert <steffen.klassert@secunet.com>
