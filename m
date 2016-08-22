From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: Only add l3mdev oif to dst lookups
Date: Mon, 22 Aug 2016 09:16:35 +0200
Message-ID: <20160822071634.GD3735@gauss.secunet.com>
References: <1471229576-29981-1-git-send-email-dsa@cumulusnetworks.com>
 <20160817.193114.794021773593737364.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:41399 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752446AbcHVHQm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 03:16:42 -0400
Content-Disposition: inline
In-Reply-To: <20160817.193114.794021773593737364.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2016 at 07:31:14PM -0400, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Sun, 14 Aug 2016 19:52:56 -0700
> 
> > Subash reported that commit 42a7b32b73d6 ("xfrm: Add oif to dst lookups")
> > broke a wifi use case that uses fib rules and xfrms. The intent of
> > 42a7b32b73d6 was driven by VRFs with IPsec. As a compromise relax the
> > use of oif in xfrm lookups to L3 master devices only (ie., oif is either
> > an L3 master device or is enslaved to a master device).
> > 
> > Fixes: 42a7b32b73d6 ("xfrm: Add oif to dst lookups")
> > Reported-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> > Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> 
> Steffen, please pick this up.

Now applied to the ipsec tree, thanks a lot!
