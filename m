From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec] xfrm: release dst_orig in case of error in
 xfrm_lookup()
Date: Thu, 12 Feb 2015 10:50:04 +0100
Message-ID: <20150212095004.GI13046@secunet.com>
References: <1423674636-4227-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, huaibin Wang <huaibin.wang@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53223 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755219AbbBLJuK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2015 04:50:10 -0500
Content-Disposition: inline
In-Reply-To: <1423674636-4227-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 11, 2015 at 06:10:36PM +0100, Nicolas Dichtel wrote:
> From: huaibin Wang <huaibin.wang@6wind.com>
> 
> dst_orig should be released on error. Function like __xfrm_route_forward()
> expects that behavior.
> Since a recent commit, xfrm_lookup() may also be called by xfrm_lookup_route(),
> which expects the opposite.
> Let's introduce a new flag (XFRM_LOOKUP_KEEP_DST_REF) to tell what should be
> done in case of error.
> 
> Fixes: f92ee61982d("xfrm: Generate blackhole routes only from route lookup functions")
> Signed-off-by: huaibin Wang <huaibin.wang@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks everyone!
