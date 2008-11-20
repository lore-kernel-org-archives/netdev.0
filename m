From: Kostya B <bkostya@hotmail.com>
Subject: RE: SKB truesize bug
Date: Thu, 20 Nov 2008 11:59:28 +0000
Message-ID: <COL107-W365F57B30278309D1E88F9B60C0@phx.gbl>
References: <BAY121-W44CAF03A4C79BFC4FEEEBDB6DE0@phx.gbl>
	<20080429.032714.263350536.davem@davemloft.net>
  	<20080429120713.GA19937@gondor.apana.org.au>
  <20080429.223747.211215854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1255"
Content-Transfer-Encoding: 8bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from col0-omc1-s2.col0.hotmail.com ([65.55.34.12]:24947 "EHLO
	col0-omc1-s2.col0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754733AbYKTL73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 06:59:29 -0500
In-Reply-To: <20080429.223747.211215854.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

Perhaps we should take a closer look on pskb_expand_head()

And add 

+skb->truesize = size + sizeof(struct sk_buff);


Kostya

_________________________________________________________________
Invite your mail contacts to join your friends list with Windows Live Spaces. It's easy!
http://spaces.live.com/spacesapi.aspx?wx_action=create&wx_url=/friends.aspx&mkt=en-us
