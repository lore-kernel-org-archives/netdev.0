From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v2 03/12] net: flow: implement flow cache for
 get routines
Date: Wed, 14 Jan 2015 21:52:32 +0000
Message-ID: <20150114215232.GF2105@casper.infradead.org>
References: <20150113212941.13874.48692.stgit@nitbit.x32>
 <20150113213621.13874.40461.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, gerlitz.or@gmail.com, jhs@mojatatu.com,
	andy@greyhouse.net, davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33647 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754123AbbANVwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 16:52:33 -0500
Content-Disposition: inline
In-Reply-To: <20150113213621.13874.40461.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/15 at 01:36pm, John Fastabend wrote:
> I chose rhashtable to get the dynamic resizing. I could use arrays
> but I don't want to pre-allocate large cache tables when we may
> never use them.
> 
> One oddity in the rhashtable implementation is there is no way
> AFAICS to do delayed free's so we use rcu_sync heavily. This should be
> fine, get operations shouldn't be a used heavily.

John, can you please clarify a bit, I'm not sure I understand. Are you
talking about delayed freeing of the table itself or elements?

The Netlink usage would be an example of a user with delayed element
freeing.

I'm glad to add whatever is required.
