From: Joe Perches <joe@perches.com>
Subject: Re: rfc: netfilter: Unhide FWINV macro arguments ?
Date: Fri, 17 Jun 2016 08:41:59 -0700
Message-ID: <1466178119.19647.110.camel@perches.com>
References: <1466101259.19647.51.camel@perches.com>
	 <20160617115932.GA5482@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0123.hostedemail.com ([216.40.44.123]:53502 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755699AbcFQPmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 11:42:07 -0400
In-Reply-To: <20160617115932.GA5482@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-06-17 at 13:59 +0200, Pablo Neira Ayuso wrote:
> On Thu, Jun 16, 2016 at 11:20:59AM -0700, Joe Perches wrote:
> > There are several FWINV #defines with identical form
> > that hide a specific structure variable and dereference
> > it with a invflags member.
> Right, this macro is obscure indeed.
[]
> I'll be taking a patch to sort out this. Thanks.

I'll wait until you pick up or reject the
ether_addr_equal_masked patch as that changes
a few FWINV uses.
