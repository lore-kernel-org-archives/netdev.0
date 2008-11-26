From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: make skb_truesize_bug() call WARN()
Date: Tue, 25 Nov 2008 21:08:27 -0800 (PST)
Message-ID: <20081125.210827.03610448.davem@davemloft.net>
References: <1227636139.3109.11.camel@achroite>
	<20081125.135434.164058659.davem@davemloft.net>
	<20081125141511.5eedb12a@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: arjan@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36189
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753231AbYKZFI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 00:08:27 -0500
In-Reply-To: <20081125141511.5eedb12a@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjan van de Ven <arjan@infradead.org>
Date: Tue, 25 Nov 2008 14:15:11 -0800

> On Tue, 25 Nov 2008 13:54:34 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > > I think there may be some value in them: users who want to help
> > > debug this can experiment to see which configurations or traffic
> > > types do or don't result in invalid truesize.
> > 
> > Agreed, netlimit'ing this is the best way to go.
> 
> ok
...
> Subject: [PATCH] net: make skb_truesize_bug() call WARN()

Applied, thanks a lot Arjan.
