From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH RFC 3/7] netfilter: add NF_INET_LOCAL_SOCKET_IN chain type
Date: Fri, 2 Oct 2015 13:07:56 +0200
Message-ID: <20151002110756.GA29822@salvia>
References: <1443525140-13493-1-git-send-email-daniel@zonque.org>
 <1443525140-13493-4-git-send-email-daniel@zonque.org>
 <20150929211959.GF19923@breakpoint.cc>
 <560B8E25.7050801@zonque.org>
 <20151001171323.GA4890@localhost.localdomain>
 <560DA092.60100@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Florian Westphal <fw@strlen.de>, daniel@iogearbox.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	balazs.scheidler@balabit.com
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42216 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751329AbbJBLBE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2015 07:01:04 -0400
Content-Disposition: inline
In-Reply-To: <560DA092.60100@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 01, 2015 at 11:07:30PM +0200, Daniel Mack wrote:
[...]
> That, however, got rejected because it doesn't work for multicast. This
> patch set implements one of the things Pablo suggested in his reply.

People are rising valid concerns here, so far we got a RFC where you
say that you don't have a proper setup to validate performance impact.

>From the locking front, you indicated that there are possible problems
in this RFC, although you claim those can be fixed.

No examples on how you will use this are shown, which has triggered
questions on how you plan to use this. Only one use-case that has been
described in natural language.

Rergading inconsistent behaviour when no process are listening, your
argument is that "that can be documented".

Frankly, I would expect you do the work from your side to justify the
inclusion of this, and that requires that your cover open fronts from
the technical side, not just arguing.

Thanks.
