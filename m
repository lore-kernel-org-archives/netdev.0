From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Fri, 13 Feb 2009 15:49:46 +0300
Message-ID: <20090213124946.GB23879@ioremap.net>
References: <20090129172030.GA2189@ioremap.net> <49905531.3030503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from genesysrack.ru ([195.178.208.66]:53406 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752371AbZBMMtt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Feb 2009 07:49:49 -0500
Content-Disposition: inline
In-Reply-To: <49905531.3030503@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick.

On Mon, Feb 09, 2009 at 05:09:21PM +0100, Patrick McHardy (kaber@trash.net) wrote:
> Sorry for ignoring this for so long. I really don't have much of an
> opinion on this except for what I said before:
> 
> - I would prefer a mechanism built on u32 if possible

u32 actually can not be used here, since it is not possible to implement
a state machine to match different wildcards for MSS for example. Like
modulus operation.

-- 
	Evgeniy Polyakov
