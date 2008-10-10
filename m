From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: drivers/net/enic/vnic_cq.c
Date: Thu, 9 Oct 2008 22:16:47 -0700
Message-ID: <20081009221647.8026269d.akpm@linux-foundation.org>
References: <20081009211217.5f4e5f77.akpm@linux-foundation.org>
	<20081009.211552.20994950.davem@davemloft.net>
	<20081009212755.94fe11f6.akpm@linux-foundation.org>
	<20081009.215452.193703022.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60986 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751543AbYJJFRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 01:17:00 -0400
In-Reply-To: <20081009.215452.193703022.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 09 Oct 2008 21:54:52 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Thu, 9 Oct 2008 21:27:55 -0700
> 
> > We have a driver which has never been compileable on i386 which has
> > slipped through at least three sets of fingers only to land on the
> > usual guy's head.
> 
> The person who submitted the driver compiled it on his box,
> I made sure to hit sparc64 to try and hit the whacky cases,
> and I'm only doing these driver merges because Jeff Garzik
> is out of town so give me a break :-)))

yup.

Thing is, since 10AM this morning I've looked at no mailing list
traffic, reviewed no patches, merged no patches.  I've spent half the
day getting all the trees merged (and I last did it 24 hours ago) and
the other half weeding out compilation errors.  I have this starry-eyed
theory that I shouldn't need to do any of this.

The stephen/me function is a single point of failure and right now,
it has failed.  I have to push back.

