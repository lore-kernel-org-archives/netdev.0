From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Thu, 22 Jan 2015 13:37:13 +0000
Message-ID: <20150122133713.GA25797@casper.infradead.org>
References: <20150120202404.1741.8658.stgit@nitbit.x32>
 <20150122125246.GA4486@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net,
	gerlitz.or@gmail.com, andy@greyhouse.net, ast@plumgrid.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41927 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbbAVNhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 08:37:16 -0500
Content-Disposition: inline
In-Reply-To: <20150122125246.GA4486@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/15 at 01:52pm, Pablo Neira Ayuso wrote:
> Hi John,
> 
> On Tue, Jan 20, 2015 at 12:26:13PM -0800, John Fastabend wrote:
> > I believe I addressed all the comments so far except for the integrate
> > with 'tc'. I plan to work on the integration pieces next.
> 
> I think that postponing the integration with 'tc' means that we're
> renouncing to provide some abstraction to represent the actions that
> the device provides. After this patch we'll have a standard API that
> exposes the vendor specific semantics, *so user configurations will
> not be portable anymore*.
> 
> At least, we should come up with some abstraction / mapping as
> interface, so the vendors can use them to represent their operations.
> That interface will provide a trade-off: If the vendor offers an
> operation that doesn't map to our abstraction, then sorry that
> operation has to remain behind the curtain.

I thought this *is* the abstraction ;-) Can you elaborate on which
parts you consider vendor specific?
