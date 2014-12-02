From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] net: mvneta: fix Tx interrupt delay
Date: Tue, 2 Dec 2014 14:24:12 +0100
Message-ID: <20141202132412.GC16347@1wt.eu>
References: <20141202071304.GA22512@1wt.eu> <1417522688.5303.35.camel@edumazet-glaptop2.roam.corp.google.com> <20141202123951.GA16347@1wt.eu> <1417525458.5303.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Maggie Mae Roxas <maggie.mae.roxas@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:29172 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754592AbaLBNYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2014 08:24:15 -0500
Content-Disposition: inline
In-Reply-To: <1417525458.5303.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 02, 2014 at 05:04:18AM -0800, Eric Dumazet wrote:
> On Tue, 2014-12-02 at 13:39 +0100, Willy Tarreau wrote:
> > Hi Eric,
> > 
> > On Tue, Dec 02, 2014 at 04:18:08AM -0800, Eric Dumazet wrote:
> > 
> > > I highly suggest BQL for this driver, now this issue is fixed.
> > 
> > How does that work ?
> 
> This works very well ;)
> 
> Its super easy to implement, take a look at commits
> bdbc063129e811264cd6c311d8c2d9b95de01231 or
> 7070ce0a6419a118842298bc967061ad6cea40db

Thanks but I'm not sure I entirely understand the concept. Is it to
notify the sender that the packets were already queued for the NIC ?
And if so, how does that improve the situation ? I'm sorry if this
sounds like a stupid question, it's just that the concept by itself
is not clear to me.

Willy
