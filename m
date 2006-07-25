From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip multicast route bug fix
Date: Tue, 25 Jul 2006 16:45:27 -0700 (PDT)
Message-ID: <20060725.164527.04738467.davem@davemloft.net>
References: <20060725162001.GA15058@ms2.inr.ac.ru>
	<20060725085528.38b86319@localhost.localdomain>
	<20060725211725.GA24366@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52356
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030260AbWGYXpM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 19:45:12 -0400
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <20060725211725.GA24366@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Wed, 26 Jul 2006 01:17:25 +0400

> Hello!
> 
> > Wouldn't it be better to have a consistent interface (skb always freed),
> > and clone the skb if needed for deferred processing?
> 
> I think you mean this.
> 
> Note, it is real skb_clone(), not alloc_skb(). Equeued skb contains
> the whole half-prepared netlink message plus room for the rest.
> It could be also skb_copy(), if we want to be puristic about mangling
> cloned data, but original copy is really not going to be used.  

Applied, thanks Alexey.
