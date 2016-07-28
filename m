From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH] xfrm: Add option to reset oif in xfrm lookup
Date: Thu, 28 Jul 2016 07:08:28 +0200
Message-ID: <20160728050828.GJ5710@gauss.secunet.com>
References: <1469493272-14894-1-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>,
	<herbert@gondor.apana.org.au>
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:33869 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752636AbcG1FIc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jul 2016 01:08:32 -0400
Content-Disposition: inline
In-Reply-To: <1469493272-14894-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 25, 2016 at 06:34:32PM -0600, Subash Abhinov Kasiviswanathan wrote:
> We are seeing incorrect routing when tunneling packets over an
> interface and sending it over another interface. This scenario
> worked on 3.18 (and earlier) and failed on 4.4 kernel. The rules
> / routes / policies were the same across kernels.
> 
> Commit 42a7b32b73d6 ("xfrm: Add oif to dst lookups") allowed
> preservation of the oif from a raw packet to a transformed packet.
> This causes issues with forwarding scenarios where the
> existing oif causes an incorrect route lookup.
> 
> Create a new sysctl which resets oif in xfrm policy. Default value
> is 0 which means that oif is preserved on transform.

Please don't try to workaround a bug with a sysctl.
If we have a bug here, we should fix it. Choosing
between bug A and bug B with a sysctl is not what
we are doing ;)
