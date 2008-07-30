From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Wed, 30 Jul 2008 15:04:54 -0700
Message-ID: <20080730150454.7612912f.akpm@linux-foundation.org>
References: <200807301939.m6UJd5lT012610@imap1.linux-foundation.org>
	<20080730133727.7774de6a@extreme>
	<20080730224849.59852c68@surf>
	<20080730140136.42223e3c@extreme>
	<20080730233551.76fd38a8@surf>
	<20080730144812.a71156f7.akpm@linux-foundation.org>
	<20080730235231.71f1b2f9@surf>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jeff@garzik.org, netdev@vger.kernel.org,
	davem@davemloft.net, mpm@selenic.com
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37287 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760004AbYG3WF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 18:05:56 -0400
In-Reply-To: <20080730235231.71f1b2f9@surf>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Jul 2008 23:52:31 +0200
Thomas Petazzoni <thomas.petazzoni@free-electrons.com> wrote:

> Oops, sorry. [1] should have been
> http://free-electrons.com/articles/conferences/elc2008-report#mackall.
> 
> __
> The graph showed an increase of 28% on the kernel size over the last
> two and half years. Over the last year, between 2.6.21 and 2.6.25-rc8,
> the kernel size of the same allnoconfig has increased from 1.06
> megabytes to 1.21 megabytes, a 14% increase.

OK.

I don't really trust allnoconfig as a way of determining size changes. 
It can easily be the case that kernel A's allnoconfig happens to pull
in more stuff than kernel B's allnoconfig.

So I do think that one should dive into the details and verify that
particular size changes really are due to unavoidable code bloat,
rather than being due to some unfortunate Kconfig change.

Tht being said, yes, I'm sure that it's getting bigger, overall.
