From: David Miller <davem@davemloft.net>
Subject: Re: dev_ifname32() fails on 32->64bit calls in copy_in_user().
Date: Tue, 30 Oct 2007 20:41:10 -0700 (PDT)
Message-ID: <20071030.204110.216540107.davem@davemloft.net>
References: <20071031003850.GE7517@tasint.org>
	<1193798124.9928.91.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joel.Becker@oracle.com, netdev@vger.kernel.org,
	Linux-Kernel@vger.kernel.org, ebiederm@xmission.com
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45288
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752481AbXJaDlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 23:41:10 -0400
In-Reply-To: <1193798124.9928.91.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 31 Oct 2007 13:35:24 +1100

> [PATCH] Fix new dev_ifname32 returning -EFAULT
> 
> A stray semicolon slipped in the patch that updated dev_ifname32 to
> not be inline, causing it to always return -EFAULT. This fixes it.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Applied, thanks for the fix Ben!
