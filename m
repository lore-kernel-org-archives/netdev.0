From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [PATCH V6 net-next 2/2] smc: introduce socket family AF_SMC
Date: Fri, 25 Sep 2015 09:27:13 +0200
Message-ID: <1443166033.6021.6.camel@BR9GV9YG.de.ibm.com>
References: <1442227366-79236-1-git-send-email-ubraun@linux.vnet.ibm.com>
	 <1442227366-79236-3-git-send-email-ubraun@linux.vnet.ibm.com>
	 <20150921.114425.119948328742744162.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: utz.bacher@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, ursula.braun@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp06.uk.ibm.com ([195.75.94.102]:40383 "EHLO
	e06smtp06.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbbIYH1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 03:27:21 -0400
Received: from /spool/local
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 25 Sep 2015 08:27:19 +0100
In-Reply-To: <20150921.114425.119948328742744162.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-09-21 at 11:44 -0700, David Miller wrote:
...
> This is a huge and complex submission and I'm already burnt out
> reading the changes thus far.
> 
> You have a lot to fix up and you can expect many revisions to be
> necessary before these changes are ready for integration upstream.
> And that's if you are lucky and someone actually continues to review
> this work.
> 
Hi Dave,

I appreciate the time you have already spent analyzing my SMC code. It
is large and complex, and I understand that you are not willing to spend
the time to review the overall code in future iterations. Before me
spending more time on SMC, I need a hint about *your* preferred way to
submit that large piece of code in general, and about the overall future
of SMC:

- Supposed the SMC code is improved to an acceptable quality and maybe
even gets additional reviewers, are you willing to accept the code at
all, given it is self-contained (our own can of worms, as you said)?
 
- I realized that I have to split up the large chunk of code into
smaller patches. Do you prefer going with a first minimal self contained
patch set first, providing basic communication capabilities, and then
incrementally add features like failover, setsockopt, urgent-data etc.
over time? Or, on submissions, do you always want to see a patch series
of the full set of features and values according to the SMC design?

Kind regards,
Ursula
