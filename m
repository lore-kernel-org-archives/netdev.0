From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6: syncookies: do not skip ->iif
 initialization
Date: Tue, 15 Jun 2010 18:10:42 -0700 (PDT)
Message-ID: <20100615.181042.98892458.davem@davemloft.net>
References: <1276464579-4399-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ggriffin.kernel@gmail.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37641
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752168Ab0FPBKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 21:10:31 -0400
In-Reply-To: <1276464579-4399-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sun, 13 Jun 2010 23:29:39 +0200

> When syncookies are in effect, req->iif is left uninitialized.
> In case of e.g. link-local addresses the route lookup then fails
> and no syn-ack is sent.
> 
> Rearrange things so ->iif is also initialized in the syncookie case.
> 
> want_cookie can only be true when the isn was zero, thus move the want_cookie
> check into the "!isn" branch.
> 
> Cc: Glenn Griffin <ggriffin.kernel@gmail.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks.
