From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Avoid transmits during sky2_down()
Date: Mon, 3 Aug 2009 08:59:24 -0700
Message-ID: <20090803085924.2b92b7b1@nehalam>
References: <392fb48f0907310457t15d8f9bbmdf77f062c423a475@mail.gmail.com>
	<20090802.130912.180264634.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mikem@ring3k.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50697 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755345AbZHCQAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 12:00:13 -0400
In-Reply-To: <20090802.130912.180264634.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 02 Aug 2009 13:09:12 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Mike McCormack <mikem@ring3k.org>
> Date: Fri, 31 Jul 2009 20:57:42 +0900
> 
> > I am aware you object to storing extra state, but I can't see a way
> > around this. Without remembering that we're restarting,
> > netif_wake_queue() is called in the ISR from sky2_tx_complete(), and
> > netif_tx_lock() is used in sky2_tx_done().  If anybody can see a way
> > around this, please let me know.
> 
> Stephen please do something about this, soon.
> 
> Michael has been trying to get this fixed for more than a month, and
> if you don't have a better fix like right now then we should put his
> fix in for the time being.
> 
> Sky2 patches are ones that consistently rot in patchwork and I'd
> appreciate if it that trend would cease, thanks.

Well, Mike's next set of patches is great, so the wait was worth it.

Some of us developer's get paid for doing things. There was a little
thing like a major release from our small engineering organization
at Vyatta to get done. Unlike the cushy life at other companies, in
a small company the engineers have to deal with customer issues,
bugzilla bugs.

