From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] xfrm_policy_destroy: rename and relative fixes
Date: Mon, 07 Jan 2008 22:34:43 -0800 (PST)
Message-ID: <20080107.223443.193158042.davem@davemloft.net>
References: <20080103120550.GB2498@hacking>
	<20080108061516.GD2529@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52261
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751321AbYAHGep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 01:34:45 -0500
In-Reply-To: <20080108061516.GD2529@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 8 Jan 2008 17:15:16 +1100

> On Thu, Jan 03, 2008 at 08:05:50PM +0800, WANG Cong wrote:
> > 
> > Since __xfrm_policy_destroy is used to destory the resources
> > allocated by xfrm_policy_alloc. So using the name
> > __xfrm_policy_destroy is not correspond with xfrm_policy_alloc.
> > Rename it to xfrm_policy_destroy.
> > 
> > And along with some instances that call xfrm_policy_alloc
> > but not using xfrm_policy_destroy to destroy the resource,
> > fix them.
> > 
> > Cc: David Miller <davem@davemloft.net>
> > Cc: Herbert Xu <herbert@gondor.apana.org.au>
> > Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
> 
> This patch looks OK to me.

Applied, thanks everyone.
