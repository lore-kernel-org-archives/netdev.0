From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] ip multicast route bug fix
Date: Tue, 25 Jul 2006 14:24:43 -0700
Message-ID: <20060725142443.42969ea6@localhost.localdomain>
References: <20060719145716.4cb9e7e2@localhost.localdomain>
	<20060725162001.GA15058@ms2.inr.ac.ru>
	<20060725085528.38b86319@localhost.localdomain>
	<20060725211725.GA24366@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:13255 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964861AbWGYVY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2006 17:24:59 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060725211725.GA24366@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 26 Jul 2006 01:17:25 +0400
Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:

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
> 
> Alexey
> 

That is what I was thinking of. Doesn't matter copy or clone, I prefer
clone.
