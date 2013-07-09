From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: rename low latency sockets functions to
 busy poll
Date: Mon, 08 Jul 2013 19:27:06 -0700 (PDT)
Message-ID: <20130708.192706.1245480344087449229.davem@davemloft.net>
References: <CA+55aFxgrOtsv7vCtic97ehpvqyezCzDcyqHVD+821BiTuiRtw@mail.gmail.com>
	<51DAF373.4040606@linux.intel.com>
	<CA+55aFwWAmHhYaPWVm7rsqiD9+RhDPpgVC1yWc0oNmP38bty4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eliezer.tamir@linux.intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	dwmw2@infradead.org, eliezer@tamir.org.il
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736Ab3GIC1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 22:27:07 -0400
In-Reply-To: <CA+55aFwWAmHhYaPWVm7rsqiD9+RhDPpgVC1yWc0oNmP38bty4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 8 Jul 2013 12:37:06 -0700

> I think it's getting closer, and I'm ok with the last final details
> being sorted out later. I just can't reasonably test any of my
> suggestions, so I'd like to get it to a point where when I pull, I
> don't feel like I'm pulling core code that I really detest. And the
> VFS layer in particular I'm pretty attached to.

So I've applied Eliezer's rename patch and will send another pull
request once he also takes care of the reduction of the number and
size of the variables used to track the poll timestamps.

Thanks.
