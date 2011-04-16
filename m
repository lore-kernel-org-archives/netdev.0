From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/3] irq: Add registered affinity guidance infrastructure
Date: Fri, 15 Apr 2011 22:11:48 -0400
Message-ID: <20110416021148.GC2200@neilslaptop.think-freely.org>
References: <1302898677-3833-1-git-send-email-nhorman@tuxdriver.com>
 <1302898677-3833-2-git-send-email-nhorman@tuxdriver.com>
 <alpine.LFD.2.00.1104160144370.2744@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	nhorman <nhorman@devel2.think-freely.org>,
	Dimitris Michailidis <dm@chelsio.com>,
	David Howells <dhowells@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52732 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755492Ab1DPCMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 22:12:10 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1104160144370.2744@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 16, 2011 at 02:22:58AM +0200, Thomas Gleixner wrote:
> On Fri, 15 Apr 2011, Neil Horman wrote:
> 
> > From: nhorman <nhorman@devel2.think-freely.org>
> > 
> > This patch adds the needed data to the irq_desc struct, as well as the needed
> > API calls to allow the requester of an irq to register a handler function to
> > determine the affinity_hint of that irq when queried from user space.
> 
> This changelog simply sucks. It does not explain the rationale for
> this churn at all.
> 
It seems pretty clear to me.  It allows a common function to update the value of
affinity_hint when its queried.

> Which problem is it solving?
> Why are the current interfaces not sufficient?
Did you read the initial post that I sent with it?  Apparently not.  Apologies,
its seems my git-send-email didn't cc everyone I expected it to:
http://marc.info/?l=linux-netdev&m=130291921026187&w=2

I'll skip the rest of your your email, and just try to turn some of your rant
into something more acceptible to you.
Neil
