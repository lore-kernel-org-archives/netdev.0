From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] net: mvneta: fix race condition in mvneta_tx()
Date: Tue, 2 Dec 2014 13:40:43 +0100
Message-ID: <20141202124043.GB16347@1wt.eu>
References: <20141202071304.GA22512@1wt.eu> <1417522688.5303.35.camel@edumazet-glaptop2.roam.corp.google.com> <1417523459.5303.39.camel@edumazet-glaptop2.roam.corp.google.com> <1417523835.5303.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Maggie Mae Roxas <maggie.mae.roxas@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:29121 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211AbaLBMko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2014 07:40:44 -0500
Content-Disposition: inline
In-Reply-To: <1417523835.5303.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 02, 2014 at 04:37:15AM -0800, Eric Dumazet wrote:
> On Tue, 2014-12-02 at 04:30 -0800, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > mvneta_tx() dereferences skb to get skb->len too late,
> > as hardware might have completed the transmit and TX completion
> > could have freed the skb from another cpu.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> 
> 
> For completeness, this bug was added in linux-3.14 and seems a stable
> candidate.
> 
> Fixes: 71f6d1b31fb1 ("net: mvneta: replace Tx timer with a real interrupt")

Absolutely, we backported this one back to 3.10.

Thanks Eric!
Willy
