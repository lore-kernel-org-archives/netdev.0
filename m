From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Wed, 30 Jul 2008 14:48:12 -0700
Message-ID: <20080730144812.a71156f7.akpm@linux-foundation.org>
References: <200807301939.m6UJd5lT012610@imap1.linux-foundation.org>
	<20080730133727.7774de6a@extreme>
	<20080730224849.59852c68@surf>
	<20080730140136.42223e3c@extreme>
	<20080730233551.76fd38a8@surf>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jeff@garzik.org, netdev@vger.kernel.org,
	davem@davemloft.net, mpm@selenic.com
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58810 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753425AbYG3VtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 17:49:07 -0400
In-Reply-To: <20080730233551.76fd38a8@surf>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Jul 2008 23:35:51 +0200
Thomas Petazzoni <thomas.petazzoni@free-electrons.com> wrote:

> Le Wed, 30 Jul 2008 14:01:36 -0700,
> Stephen Hemminger <shemminger@vyatta.com> a __crit :
> 
> > Yes, but still concerned that the loss of functionality. The kernel
> > developers have been preaching to get rid of module parameters for
> > configuration, and use a standard interfaces such as ethtool;then the
> > embedded folks want to save a meager 6K.
> 
> I understand your point, and I understand that adding many
> configuration options might not look pretty to everybody (even to me).
> However, the kernel developers want to keep embedded people using recent
> versions of the Linux kernel. Unfortunately, the kernel grows release
> after release (see [1] for a report, for example),

There is no [1].

>  making the kernel
> less and less usable in certain constrainted embedded contexts where
> older kernels can be used. And people putting Linux in consumer
> electronics devices sold several millions times really do care about
> system size.
> 
> The problem is that this kernel growth is well-spread over all the code.
> So yes, it's 6k here, 10k here, 7k there, but once added, it starts to
> be significant.

I note that everybody thinks that their bit cannot possibly be removed,
and that everyone else's can ;)

But I do think we should see some evidence that people are actually
using CONFIG_ETHTOOL=n in real setups.


