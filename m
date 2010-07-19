From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 2.6.35-rc3] drivers/net: ks8842 driver
Date: Mon, 19 Jul 2010 15:45:00 -0700
Message-ID: <20100719154500.a7cc2fb7.akpm@linux-foundation.org>
References: <C43529A246480145B0A6D0234BDB0F0D0212A7@MELANITE.micrel.com>
	<20100713.101434.180417674.davem@davemloft.net>
	<20100719151725.fc11b40d.akpm@linux-foundation.org>
	<20100719.152621.93431422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David.Choi@Micrel.Com, netdev@vger.kernel.org,
	Charles.Li@Micrel.Com, horms@verge.net.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51252 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966583Ab0GSWpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 18:45:36 -0400
In-Reply-To: <20100719.152621.93431422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Jul 2010 15:26:21 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> David Choi, I'm quite upset, this shows that you did not test the
> 16-bit code paths (the whole _point_ of this change) at all.

The code could have passed runtime testing by luck.

> You didn't even validate the build for new warnings.

yeah.  The kernel build is such a stinky mess of warnings that it's
easy to miss new ones.  You're basically forced to manually compile the
files which you touched to see if you added warnings.

That's pretty easy to do:

- unapply your patch
- make
- apply your patch
- make

and `make' will go and build just the files you affected.

We really should be more aggressive about all those warnings though.
