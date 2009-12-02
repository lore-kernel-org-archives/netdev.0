From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sch_htb: ix the deficit overflows
Date: Wed, 2 Dec 2009 10:32:04 +0000
Message-ID: <20091202103204.GA7724@ff.dom.local>
References: <20091128000401.GA3713@ami.dom.local> <412e6f7f0911292026w704a70b8yc3af2c2473e05d34@mail.gmail.com> <20091130111020.GA7114@ff.dom.local> <20091202.012017.39623676.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiaosuo@gmail.com, hadi@cyberus.ca, netdev@vger.kernel.org,
	martin.devera@cdi.cz
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:62616 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751278AbZLBKcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 05:32:06 -0500
Received: by bwz27 with SMTP id 27so41264bwz.21
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2009 02:32:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091202.012017.39623676.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 02, 2009 at 01:20:17AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 30 Nov 2009 11:10:20 +0000
> 
> > On Mon, Nov 30, 2009 at 12:26:33PM +0800, Changli Gao wrote:
> >> And
> >> if we use IMQ to shape traffic, the skb will be defragmented by
> >> conntrack, and its size will be larger than MTU.
> > 
> > IMQ is a very nice thing, but it's considered broken as well, so it
> > can't be the reason for changing HTB.
> 
> If you don't like IMQ, fine.  Simply consider TSO and GSO as another
> set of mechanisms that can introduce this condition.
> 
> Because we toss large SKBs all over the strack quite freely,
> protections like those suggested by Changli make perfect sense.
> 
> We really don't have an MTU for packets within our stack any more.
> The code, by default, need to be able to handle anything.

Alas, an MTU is still a crucial parameter for some schedulers. Anyway,
I hope Changli wasn't mislead to treat my private opinions in this or
any other thread as decisive. Otherwise, I'm sorry.

Jarek P.
