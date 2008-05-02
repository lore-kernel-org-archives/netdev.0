From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] (revised) net/xfrm/xfrm_policy.c: replace timer with
 delayed_work
Date: Fri, 02 May 2008 16:54:55 -0700 (PDT)
Message-ID: <20080502.165455.24687234.davem@davemloft.net>
References: <alpine.LFD.1.10.0804302355120.2940@localhost.localdomain>
	<20080501011123.GA4060@gondor.apana.org.au>
	<alpine.LFD.1.10.0805021323470.3349@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	akpm@osdl.org, netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55870
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758419AbYEBXyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 19:54:55 -0400
In-Reply-To: <alpine.LFD.1.10.0805021323470.3349@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: WANG Cong <xiyou.wangcong@gmail.com>
Date: Fri, 2 May 2008 13:35:55 +0800 (CST)

> 
> As suggested by Herbert Xu, using workqueue is better than timer
> for net/xfrm/xfrm_policy.c, so replace them with delayed_work.
> And due to this change, we have to disable BH when trying to
> lock.
> 
> Note that, this patch is not fully tested, so should be
> in -mm first.
> 
> Signed-off-by: WANG Cong <wangcong@zeuux.org>

Please let me know when these two patches have gotten some
good testing.
