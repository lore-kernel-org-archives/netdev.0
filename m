From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Wed, 30 Jul 2008 15:13:16 -0700
Message-ID: <20080730151316.a4d76fe9.akpm@linux-foundation.org>
References: <20080730140136.42223e3c@extreme>
	<20080730233551.76fd38a8@surf>
	<20080730144812.a71156f7.akpm@linux-foundation.org>
	<20080730.145727.07367670.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, shemminger@vyatta.com,
	jeff@garzik.org, netdev@vger.kernel.org, mpm@selenic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55648 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756815AbYG3WOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 18:14:34 -0400
In-Reply-To: <20080730.145727.07367670.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Jul 2008 14:57:27 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Wed, 30 Jul 2008 14:48:12 -0700
> 
> > But I do think we should see some evidence that people are actually
> > using CONFIG_ETHTOOL=n in real setups.
> 
> Heaven help them if they want to debug any real problems that
> might involve checksumming, TSO, and other offload features.
> Heaven help them if they want to probe the driver or firmware
> version of the card they are using.

Presumably they would enable ethtool (and a whole bunch of other
debugging things) during development.  In previous lives I've seen
development boards which have double the memory of production boards
simply so that the developers can get their work done.

> I'm sure you can find someone who runs with CONFIG_STAND_ON_MY_HEAD=y
> but that doesn't mean that supporting such an option upstream makes
> any sense.

Well yes, embedded developers do patch the hell out of their kernels
and presumably they will always do so.  The idea here is to bring
things inwards to reduce the amount of patching which these people need
to do.

If they don't do this then tens of millions of devices will be burdened
with many kilobytes of code which they will never ever need.

