From: Marc MERLIN <marc@merlins.org>
Subject: Re: 3.7.8/amd64 full interrupt hangs due to iwlwifi under big nfs copies out
Date: Tue, 19 Feb 2013 08:18:30 -0800
Message-ID: <20130219161830.GD21764@merlins.org>
References: <20120410051127.GA32048@merlins.org> <1334038263.2907.1.camel@edumazet-glaptop> <20120411052733.GA17352@merlins.org> <20120715215935.GF24420@merlins.org> <1342419529.3265.12217.camel@edumazet-glaptop> <20120716151826.GA10586@merlins.org> <1342455717.2830.14.camel@edumazet-glaptop> <20130219040557.GB4778@merlins.org> <1361251033.19353.120.camel@edumazet-glaptop> <1361268221.8553.1.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, Larry.Finger@lwfinger.net,
	bhutchings@solarflare.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from magic.merlins.org ([209.81.13.136]:52960 "EHLO
	mail1.merlins.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754764Ab3BSQSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 11:18:39 -0500
Content-Disposition: inline
In-Reply-To: <1361268221.8553.1.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 19, 2013 at 11:03:41AM +0100, Johannes Berg wrote:
> On Mon, 2013-02-18 at 21:17 -0800, Eric Dumazet wrote:
> 
> > > chrome: page allocation failure: order:1, mode:0x4020
> > > Pid: 8730, comm: chrome Tainted: G           O 3.7.8-amd64-preempt-20121226-fixwd #1
> > > Call Trace:
> > >  <IRQ>  [<ffffffff810d5f38>] warn_alloc_failed+0x117/0x12c
> 
> > You could try to load iwlwifi with amsdu_size_8K set to 0 (disable)
> > 
> > It should hopefully use order-0 pages
> 
> It will, do that then, unfortunately it can't switch at runtime because
> it advertised this support to the access point or clients.

Forgive the newbie question: would the inability to get pages cause
interrupts to be disabled or at least something that would stop the mouse
cursor and the keyboard from working?

Thanks,
Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  
