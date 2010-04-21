From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] cleanup: remove two unnecessary exports
 (skbuff).
Date: Tue, 20 Apr 2010 22:40:19 -0700 (PDT)
Message-ID: <20100420.224019.174353684.davem@davemloft.net>
References: <g2teb3ff54b1004202220va58efc7evdb91e2cf38b062d4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39600
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752065Ab0DUFkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 01:40:46 -0400
In-Reply-To: <g2teb3ff54b1004202220va58efc7evdb91e2cf38b062d4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Wed, 21 Apr 2010 08:20:31 +0300

> There is no need to export skb_under_panic() and skb_over_panic() in
> skbuff.c, since these methods are used only in skbuff.c ; this patch
> removes these
> two exports. It also marks these functions as 'static' and removeS the extern
> declarations of them from include/linux/skbuff.h
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.
