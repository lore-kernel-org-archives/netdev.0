From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 3.7.8/amd64 full interrupt hangs due to iwlwifi under big nfs
 copies out
Date: Tue, 19 Feb 2013 11:03:41 +0100
Message-ID: <1361268221.8553.1.camel@jlt4.sipsolutions.net>
References: <1333998672.3007.245.camel@edumazet-glaptop>
	 <20120409.153452.1284163346306246866.davem@davemloft.net>
	 <1334030180.13293.98.camel@edumazet-glaptop>
	 <20120410051127.GA32048@merlins.org>
	 <1334038263.2907.1.camel@edumazet-glaptop>
	 <20120411052733.GA17352@merlins.org> <20120715215935.GF24420@merlins.org>
	 <1342419529.3265.12217.camel@edumazet-glaptop>
	 <20120716151826.GA10586@merlins.org>
	 <1342455717.2830.14.camel@edumazet-glaptop>
	 <20130219040557.GB4778@merlins.org>
	 <1361251033.19353.120.camel@edumazet-glaptop>
	 (sfid-20130219_061917_530878_1ED7A14C)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marc MERLIN <marc@merlins.org>, David Miller <davem@davemloft.net>,
	Larry.Finger@lwfinger.net, bhutchings@solarflare.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:46363 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758567Ab3BSKEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 05:04:11 -0500
In-Reply-To: <1361251033.19353.120.camel@edumazet-glaptop> (sfid-20130219_061917_530878_1ED7A14C)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-02-18 at 21:17 -0800, Eric Dumazet wrote:

> > chrome: page allocation failure: order:1, mode:0x4020
> > Pid: 8730, comm: chrome Tainted: G           O 3.7.8-amd64-preempt-20121226-fixwd #1
> > Call Trace:
> >  <IRQ>  [<ffffffff810d5f38>] warn_alloc_failed+0x117/0x12c

> You could try to load iwlwifi with amsdu_size_8K set to 0 (disable)
> 
> It should hopefully use order-0 pages

It will, do that then, unfortunately it can't switch at runtime because
it advertised this support to the access point or clients.

johannes
