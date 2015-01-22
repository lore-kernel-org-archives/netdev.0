From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Thu, 22 Jan 2015 13:52:46 +0100
Message-ID: <20150122125246.GA4486@salvia>
References: <20150120202404.1741.8658.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net,
	gerlitz.or@gmail.com, andy@greyhouse.net, ast@plumgrid.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38969 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750832AbbAVMtw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 07:49:52 -0500
Content-Disposition: inline
In-Reply-To: <20150120202404.1741.8658.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

On Tue, Jan 20, 2015 at 12:26:13PM -0800, John Fastabend wrote:
> I believe I addressed all the comments so far except for the integrate
> with 'tc'. I plan to work on the integration pieces next.

I think that postponing the integration with 'tc' means that we're
renouncing to provide some abstraction to represent the actions that
the device provides. After this patch we'll have a standard API that
exposes the vendor specific semantics, *so user configurations will
not be portable anymore*.

At least, we should come up with some abstraction / mapping as
interface, so the vendors can use them to represent their operations.
That interface will provide a trade-off: If the vendor offers an
operation that doesn't map to our abstraction, then sorry that
operation has to remain behind the curtain.

netdev is just two weeks ahead and this is an important change IMO.
I'd rather have the chance to meet you and other fellows there and
discuss if we can come up with some glue abstraction.
