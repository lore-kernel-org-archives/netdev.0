From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH RFC 3/7] netfilter: add NF_INET_LOCAL_SOCKET_IN chain type
Date: Fri, 2 Oct 2015 15:52:06 +0200
Message-ID: <560E8C06.6040502@zonque.org>
References: <1443525140-13493-1-git-send-email-daniel@zonque.org>
 <1443525140-13493-4-git-send-email-daniel@zonque.org>
 <20150929211959.GF19923@breakpoint.cc> <560B8E25.7050801@zonque.org>
 <20151001171323.GA4890@localhost.localdomain> <560DA092.60100@zonque.org>
 <20151002110756.GA29822@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Florian Westphal <fw@strlen.de>, daniel@iogearbox.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	balazs.scheidler@balabit.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:32770 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754006AbbJBNwL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2015 09:52:11 -0400
In-Reply-To: <20151002110756.GA29822@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/02/2015 01:07 PM, Pablo Neira Ayuso wrote:
> On Thu, Oct 01, 2015 at 11:07:30PM +0200, Daniel Mack wrote:
> [...]
>> That, however, got rejected because it doesn't work for multicast. This
>> patch set implements one of the things Pablo suggested in his reply.
> 
> People are rising valid concerns here, so far we got a RFC where you
> say that you don't have a proper setup to validate performance impact.
> 
> From the locking front, you indicated that there are possible problems
> in this RFC, although you claim those can be fixed.
> 
> No examples on how you will use this are shown, which has triggered
> questions on how you plan to use this. Only one use-case that has been
> described in natural language.
> 
> Rergading inconsistent behaviour when no process are listening, your
> argument is that "that can be documented".
> 
> Frankly, I would expect you do the work from your side to justify the
> inclusion of this, and that requires that your cover open fronts from
> the technical side, not just arguing.

Sure, I'm willing to do this of course. The purpose of this RFC was only
to outline where this approach would go, and to allow discussions about
possible show stoppers.

I'll respin this in a new series then.



Thanks,
Daniel
