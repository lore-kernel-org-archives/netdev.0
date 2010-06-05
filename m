From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] syncookies: avoid unneeded tcp header
 flag double check
Date: Sat, 05 Jun 2010 02:53:32 -0700 (PDT)
Message-ID: <20100605.025332.116365111.davem@davemloft.net>
References: <1275561824-24227-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46371
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932709Ab0FEJxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 05:53:22 -0400
In-Reply-To: <1275561824-24227-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu,  3 Jun 2010 12:43:44 +0200

> caller: if (!th->rst && !th->syn && th->ack)
> callee: if (!th->ack)
> 
> make the caller only check for !syn (common for 3whs), and move
> the !rst / ack test to the callee.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
