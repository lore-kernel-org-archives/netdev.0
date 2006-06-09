From: David Miller <davem@davemloft.net>
Subject: Re: [patch 5/9] secmark: Add secmark support to core networking.
Date: Fri, 09 Jun 2006 00:29:53 -0700 (PDT)
Message-ID: <20060609.002953.70217215.davem@davemloft.net>
References: <200606090520.k595KtAs032095@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:8600
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751412AbWFIHai (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 03:30:38 -0400
To: akpm@osdl.org
In-Reply-To: <200606090520.k595KtAs032095@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Thu, 08 Jun 2006 22:20:55 -0700

> Add a secmark field to the skbuff structure, to allow security subsystems to
> place security markings on network packets.  This is similar to the nfmark
> field, except is intended for implementing security policy, rather than than
> networking policy.
> 
> This patch was already acked in principle by Dave Miller.
> 
> Signed-off-by: James Morris <jmorris@namei.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied to net-2.6.18, thanks.

Remember James, you're on the hook now to shrink sk_buff
when you get a chance :-)

Thanks again.

