From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [resend] Passive OS fingerprint xtables match.
Date: Thu, 4 Jun 2009 16:07:19 +0400
Message-ID: <20090604120719.GA14981@ioremap.net>
References: <20090511095343.GA30778@ioremap.net> <4A1D6A20.8050404@trash.net> <20090604113723.GA13018@ioremap.net> <4A27B5A1.9050300@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:37366 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754384AbZFDMHV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2009 08:07:21 -0400
Content-Disposition: inline
In-Reply-To: <4A27B5A1.9050300@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 04, 2009 at 01:53:05PM +0200, Patrick McHardy (kaber@trash.net) wrote:
> >That's hard - there is no hook number in the match function, so we do
> >not really know if it is forward, input or prerouting.
> 
> This is really needed, spamming the ring buffer is not a good option.
> 
> I'd say just add the hook number to xt_match_param. Its a bit
> inconsistent anyways that we're handing it to checkentry for
> validation, but not to the match function.

Doesn't checkentry receive a mask of all possible hooks? There is still
no per-packet hook number. Although we can always use INPUT hook since
its the most widely used one. And drop a comment about this abuse.

-- 
	Evgeniy Polyakov
