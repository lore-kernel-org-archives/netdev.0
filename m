From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v2 03/12] net: flow: implement flow cache for
 get routines
Date: Thu, 15 Jan 2015 03:24:25 +0000
Message-ID: <20150115032425.GB29974@casper.infradead.org>
References: <20150113212941.13874.48692.stgit@nitbit.x32>
 <20150113213621.13874.40461.stgit@nitbit.x32>
 <20150114215232.GF2105@casper.infradead.org>
 <54B7323D.9030506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, gerlitz.or@gmail.com, jhs@mojatatu.com,
	andy@greyhouse.net, davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35370 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbbAODY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 22:24:27 -0500
Content-Disposition: inline
In-Reply-To: <54B7323D.9030506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/15 at 07:21pm, John Fastabend wrote:
> anyways it looks like it is there no problem after all and I don't
> recall what I was thinking thanks for bearing with me. I'll convert
> this code to avoid the over-use of rcu_sync.

It's likely that you looked at this before the per bucket lock work
occured. That's when the Netlink rhashtable code was converted to RCU
with the rhashtable API changed accordingly.
