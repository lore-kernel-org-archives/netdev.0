From: Marcel Holtmann <holtmann@linux.intel.com>
Subject: Re: pull request: wireless-2.6 2008-08-26
Date: Wed, 27 Aug 2008 13:10:10 +0200
Message-ID: <1219835410.5359.24.camel@californication>
References: <20080827013009.GA15781@tuxdriver.com>
	 <1ba2fa240808270038r24d5eeb9l36fd70ef5ae904f5@mail.gmail.com>
	 <20080827.014041.230100807.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tomasw@gmail.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:49934 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754445AbYH0JKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 05:10:14 -0400
In-Reply-To: <20080827.014041.230100807.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> > Afther massive ath9k merge I didn't see it was a conceptual problem.
> 
> Stop right there.
> 
> You don't see it as a problem because you're not the one who has to
> explain all of this shit to Linus and ends up getting flamed by him
> when inappropriate changes are in my tree outside of the merge window.

I did a quick review of the offending patch queue. And some of them
should go in since they are fixing real bugs (as far as I can tell from
a quick review). Others have to clearly wait for the next merge window.

Thomas, please go through the list of patches and pick the real bug
fixes. The cleanup patches can't go in since they are after the merge
window. And being one of the offenders why Dave got flamed by Linus,
there is no way to get these through. And my big offender was a
regression that broke userspace and came with a lengthy commit message.

Speaking of which, you better have a more convincing commit message if
you wanna get something in after the merge window. It should make clear
why this is a bug or a regression and why it can't wait until the next
merge window.

Please take this into account for any future patches since Linus now set
a really high bar for patches after the merge window.

Regards

Marcel


