From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: fix management of driver LED
Date: Tue, 1 Sep 2009 21:33:25 -0700
Message-ID: <20090901213325.69b3348b@nehalam>
References: <4A9928C9.7000907@ring3k.org>
	<20090831103141.77598705@nehalam>
	<20090901.174437.145971351.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mikem@ring3k.org, netdev@vger.kernel.org,
	rene.mayrhofer@gibraltar.at, leitner@esys.at
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35237 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752848AbZIBEeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 00:34:04 -0400
In-Reply-To: <20090901.174437.145971351.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 01 Sep 2009 17:44:37 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Mon, 31 Aug 2009 10:31:41 -0700
> 
> > Observed by Mike McCormack.
> > 
> > The LED bit here is just a software controlled value used to
> > turn on one of the LED's on some boards. The register value was wrong,
> > which could have been causing some power control issues.
> > Get rid of problematic define use the correct mask.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Applied.

If these power management fixes do fix all the reported problems,
then I will consider back porting (probably to 2.6.31.1).


-- 
