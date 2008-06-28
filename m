From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IRDA: Fix genlmsg_put() return value check.
Date: Fri, 27 Jun 2008 20:01:33 -0700 (PDT)
Message-ID: <20080627.200133.71838192.davem@davemloft.net>
References: <f4845fc0806231329p7ef94a8dqafe63feea89ad949@mail.gmail.com>
	<1214299754-27769-1-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, samuel@sortiz.org, netdev@vger.kernel.org
To: juliusv@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45932
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752220AbYF1DBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 23:01:33 -0400
In-Reply-To: <1214299754-27769-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julius Volz <juliusv@google.com>
Date: Tue, 24 Jun 2008 11:29:14 +0200

> Fix an incorrect return value check of genlmsg_put() in irda_nl_get_mode().
> genlmsg_put() does not use ERR_PTR() to encode return values, it just
> returns NULL on error.
> 
> Signed-off-by: Julius Volz <juliusv@google.com>

I'm assuming Samuel will grab this and send it to me in his
next IRDA merge to me.
